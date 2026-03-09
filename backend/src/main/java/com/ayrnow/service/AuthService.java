package com.ayrnow.service;

import com.ayrnow.config.AppUrlProperties;
import com.ayrnow.config.JwtService;
import com.ayrnow.domain.User;
import com.ayrnow.dto.*;
import com.ayrnow.error.AuthException;
import com.ayrnow.error.ConflictException;
import com.ayrnow.error.RateLimitException;
import com.ayrnow.repository.UserRepository;
import com.ayrnow.util.TokenHashUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
public class AuthService {

    private static final int VERIFICATION_EXPIRY_HOURS = 24;
    private static final int RESET_EXPIRY_HOURS = 1;

    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;
    private final SesEmailService sesEmailService;
    private final AppUrlProperties appUrlProperties;
    private final AuthRateLimitService rateLimitService;

    public AuthService(UserRepository userRepository, JwtService jwtService,
                      RefreshTokenService refreshTokenService,
                      org.springframework.security.crypto.password.PasswordEncoder passwordEncoder,
                      SesEmailService sesEmailService, AppUrlProperties appUrlProperties,
                      AuthRateLimitService rateLimitService) {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.refreshTokenService = refreshTokenService;
        this.passwordEncoder = passwordEncoder;
        this.sesEmailService = sesEmailService;
        this.appUrlProperties = appUrlProperties;
        this.rateLimitService = rateLimitService;
    }

    @Transactional
    public RegisterResponse register(RegisterRequest req) {
        if (userRepository.findByEmail(req.getEmail()).isPresent()) {
            throw new ConflictException("Email already taken");
        }
        User user = createUser(req.getEmail(), req.getRole(), req.getName(), passwordEncoder.encode(req.getPassword()));
        user.setEmailVerified(false);
        String rawToken = TokenHashUtil.generateToken();
        user.setVerificationTokenHash(TokenHashUtil.hashToken(rawToken));
        user.setVerificationTokenExpiresAt(Instant.now().plusSeconds(VERIFICATION_EXPIRY_HOURS * 3600L));
        userRepository.save(user);

        String baseUrl = appUrlProperties.getAppBaseUrl();
        if (baseUrl.endsWith("/")) baseUrl = baseUrl.substring(0, baseUrl.length() - 1);
        String verifyLink = baseUrl + "/verify-email?token=" + rawToken;
        boolean emailSent = sesEmailService.sendVerificationEmail(user.getEmail(), verifyLink);

        return new RegisterResponse("Check your email to verify your account", emailSent);
    }

    @Transactional
    public LoginResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail())
                .orElseThrow(() -> new AuthException("Invalid credentials"));
        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new AuthException("Invalid credentials");
        }
        if (!user.isEmailVerified()) {
            throw new AuthException("Please verify your email before signing in.");
        }
        return generateTokens(user);
    }

    @Transactional
    public void verifyEmail(String rateLimitKey, String token) {
        if (!rateLimitService.isAllowed(rateLimitKey)) {
            throw new RateLimitException("Too many attempts. Try again later.");
        }
        String hash = TokenHashUtil.hashToken(token);
        User user = userRepository.findByVerificationTokenHash(hash)
                .orElseThrow(() -> new AuthException("Invalid or expired verification link"));
        if (user.getVerificationTokenExpiresAt() == null || user.getVerificationTokenExpiresAt().isBefore(Instant.now())) {
            throw new AuthException("Verification link has expired");
        }
        user.setEmailVerified(true);
        user.setVerificationTokenHash(null);
        user.setVerificationTokenExpiresAt(null);
        userRepository.save(user);
    }

    @Transactional
    public void forgotPassword(String rateLimitKey, String email) {
        if (!rateLimitService.isAllowed(rateLimitKey)) {
            return; // same response as success to avoid enumeration
        }
        userRepository.findByEmail(email).ifPresent(user -> {
            String rawToken = TokenHashUtil.generateToken();
            user.setResetTokenHash(TokenHashUtil.hashToken(rawToken));
            user.setResetTokenExpiresAt(Instant.now().plusSeconds(RESET_EXPIRY_HOURS * 3600L));
            userRepository.save(user);
            String baseUrl = appUrlProperties.getAppBaseUrl();
            if (baseUrl.endsWith("/")) baseUrl = baseUrl.substring(0, baseUrl.length() - 1);
            String resetLink = baseUrl + "/reset-password?token=" + rawToken;
            sesEmailService.sendPasswordResetEmail(user.getEmail(), resetLink);
        });
    }

    @Transactional
    public void resetPassword(String token, String newPassword) {
        String hash = TokenHashUtil.hashToken(token);
        User user = userRepository.findByResetTokenHash(hash)
                .orElseThrow(() -> new AuthException("Invalid or expired reset link"));
        if (user.getResetTokenExpiresAt() == null || user.getResetTokenExpiresAt().isBefore(Instant.now())) {
            throw new AuthException("Reset link has expired");
        }
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setResetTokenHash(null);
        user.setResetTokenExpiresAt(null);
        userRepository.save(user);
    }

    private LoginResponse generateTokens(User user) {
        String token = jwtService.createToken(user.getId().toString(), user.getEmail(), user.getRole());
        String refreshToken = refreshTokenService.createRefreshToken(user).getToken();
        return new LoginResponse(token, refreshToken, user.getRole(), user.getId().toString(), user.getEmail());
    }

    private User createUser(String email, String role, String name, String encodedPassword) {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setEmail(email);
        user.setName(name != null && !name.isBlank() ? name : email.split("@")[0]);
        user.setRole(role);
        user.setPasswordHash(encodedPassword);
        user.setCreatedAt(Instant.now());
        user.setEmailVerified(false);
        return userRepository.save(user);
    }

    @Transactional
    public LoginResponse refreshToken(TokenRefreshRequest request) {
        String requestRefreshToken = request.getRefreshToken();
        return refreshTokenService.findByToken(requestRefreshToken)
                .map(refreshTokenService::verifyExpiration)
                .map(token -> {
                    User user = token.getUser();
                    refreshTokenService.deleteToken(token);
                    String jwtToken = jwtService.createToken(user.getId().toString(), user.getEmail(), user.getRole());
                    String newRefreshToken = refreshTokenService.createRefreshToken(user).getToken();
                    return new LoginResponse(jwtToken, newRefreshToken, user.getRole(), user.getId().toString(), user.getEmail());
                })
                .orElseThrow(() -> new AuthException("Refresh token is not valid"));
    }
}
