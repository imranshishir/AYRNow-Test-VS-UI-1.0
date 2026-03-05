package com.ayrnow.service;

import com.ayrnow.config.JwtService;
import com.ayrnow.domain.User;
import com.ayrnow.dto.LoginRequest;
import com.ayrnow.dto.LoginResponse;
import com.ayrnow.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    public AuthService(UserRepository userRepository, JwtService jwtService, RefreshTokenService refreshTokenService, org.springframework.security.crypto.password.PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.refreshTokenService = refreshTokenService;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public LoginResponse register(com.ayrnow.dto.RegisterRequest req) {
        if (userRepository.findByEmail(req.getEmail()).isPresent()) {
            throw new RuntimeException("Email already taken");
        }
        User user = createUser(req.getEmail(), req.getRole(), req.getName(), passwordEncoder.encode(req.getPassword()));
        return generateTokens(user);
    }

    @Transactional
    public LoginResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));
        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new RuntimeException("Invalid credentials");
        }
        return generateTokens(user);
    }

    private LoginResponse generateTokens(User user) {
        String token = jwtService.createToken(user.getId().toString(), user.getEmail(), user.getRole());
        String refreshToken = refreshTokenService.createRefreshToken(user).getToken();
        return new LoginResponse(token, refreshToken, user.getRole(), user.getId().toString(), user.getEmail());
    }

    @Transactional
    public LoginResponse refreshToken(com.ayrnow.dto.TokenRefreshRequest request) {
        String requestRefreshToken = request.getRefreshToken();
        return refreshTokenService.findByToken(requestRefreshToken)
                .map(refreshTokenService::verifyExpiration)
                .map(token -> {
                    User user = token.getUser();
                    refreshTokenService.deleteToken(token); // revoke the old token
                    
                    String jwtToken = jwtService.createToken(user.getId().toString(), user.getEmail(), user.getRole());
                    String newRefreshToken = refreshTokenService.createRefreshToken(user).getToken();
                    return new LoginResponse(jwtToken, newRefreshToken, user.getRole(), user.getId().toString(), user.getEmail());
                })
                .orElseThrow(() -> new RuntimeException(requestRefreshToken + " Refresh token is not in the database!"));
    }

    private User createUser(String email, String role, String name, String encodedPassword) {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setEmail(email);
        user.setName(name != null && !name.isBlank() ? name : email.split("@")[0]);
        user.setRole(role);
        user.setPasswordHash(encodedPassword);
        user.setCreatedAt(Instant.now());
        return userRepository.save(user);
    }
}
