package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.api.dto.AuthResponse;
import com.ayrnow.config.AuthProperties;
import com.ayrnow.domain.entity.*;
import com.ayrnow.domain.repository.*;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

@Service
public class AuthService {

    private static final int REFRESH_TOKEN_BYTES = 48;

    private final AuthProperties authProperties;
    private final AccountRepository accountRepository;
    private final AppUserRepository appUserRepository;
    private final UserRoleRepository userRoleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthService(AuthProperties authProperties,
                       AccountRepository accountRepository,
                       AppUserRepository appUserRepository,
                       UserRoleRepository userRoleRepository,
                       RefreshTokenRepository refreshTokenRepository,
                       PasswordEncoder passwordEncoder) {
        this.authProperties = authProperties;
        this.accountRepository = accountRepository;
        this.appUserRepository = appUserRepository;
        this.userRoleRepository = userRoleRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public AuthResponse register(String email, String password, String displayName, String role, String accountName) {
        if (accountName == null || accountName.isBlank()) {
            throw new ConflictException("accountName is required for registration");
        }
        if (appUserRepository.findByEmail(email).isPresent()) {
            throw new ConflictException("Email already registered");
        }

        Account account = new Account();
        account.setName(accountName.trim());
        account = accountRepository.save(account);

        AppUser user = new AppUser();
        user.setAccountId(account.getId());
        user.setEmail(email.trim().toLowerCase());
        user.setDisplayName(displayName != null ? displayName.trim() : null);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setIsActive(true);
        user = appUserRepository.save(user);

        UserRole userRole = new UserRole();
        userRole.setUserId(user.getId());
        userRole.setRole(normalizeRole(role));
        userRoleRepository.save(userRole);

        return issueTokens(account.getId(), user.getId(), userRole.getRole());
    }

    public AuthResponse login(String email, String password) {
        AppUser user = appUserRepository.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new ResourceNotFoundException("Invalid email or password"));
        if (!Boolean.TRUE.equals(user.getIsActive())) {
            throw new ResourceNotFoundException("Invalid email or password");
        }
        if (user.getPasswordHash() == null || user.getPasswordHash().isBlank()) {
            throw new ResourceNotFoundException("Invalid email or password");
        }
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new ResourceNotFoundException("Invalid email or password");
        }

        List<UserRole> roles = userRoleRepository.findByUserId(user.getId());
        String role = roles.isEmpty() ? "tenant" : normalizeRole(roles.get(0).getRole());

        return issueTokens(user.getAccountId(), user.getId(), role);
    }

    @Transactional
    public AuthResponse refresh(String refreshTokenPlain) {
        String tokenHash = hashToken(refreshTokenPlain);
        RefreshToken token = refreshTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new ResourceNotFoundException("Invalid refresh token"));
        if (token.getRevokedAt() != null) {
            throw new ResourceNotFoundException("Invalid refresh token");
        }
        if (token.getExpiresAt().isBefore(Instant.now())) {
            throw new ResourceNotFoundException("Refresh token expired");
        }

        token.setRevokedAt(Instant.now());
        refreshTokenRepository.save(token);

        AuthResponse response = issueTokens(token.getAccountId(), token.getUserId(), resolveRole(token.getUserId()));
        RefreshToken newToken = refreshTokenRepository.findByTokenHash(hashToken(response.refreshToken()))
                .orElseThrow();
        token.setReplacedBy(newToken.getId());
        refreshTokenRepository.save(token);

        return response;
    }

    @Transactional
    public void logout(String refreshTokenPlain) {
        String tokenHash = hashToken(refreshTokenPlain);
        refreshTokenRepository.findByTokenHash(tokenHash).ifPresent(token -> {
            if (token.getRevokedAt() == null) {
                token.setRevokedAt(Instant.now());
                refreshTokenRepository.save(token);
            }
        });
    }

    private AuthResponse issueTokens(UUID accountId, UUID userId, String role) {
        String accessToken = createAccessToken(accountId, userId, role);
        String refreshToken = createRefreshToken();
        persistRefreshToken(refreshToken, accountId, userId);
        return new AuthResponse(accessToken, refreshToken, userId, accountId, role);
    }

    private String createAccessToken(UUID accountId, UUID userId, String role) {
        SecretKey key = Keys.hmacShaKeyFor(authProperties.getJwt().getSecret().getBytes(StandardCharsets.UTF_8));
        Instant exp = Instant.now().plusSeconds(authProperties.getJwt().getAccessMinutes() * 60L);
        return Jwts.builder()
                .subject(userId.toString())
                .claim("accountId", accountId.toString())
                .claim("role", role)
                .expiration(java.util.Date.from(exp))
                .issuedAt(java.util.Date.from(Instant.now()))
                .signWith(key)
                .compact();
    }

    private String createRefreshToken() {
        byte[] bytes = new byte[REFRESH_TOKEN_BYTES];
        new java.security.SecureRandom().nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private void persistRefreshToken(String refreshTokenPlain, UUID accountId, UUID userId) {
        int days = authProperties.getRefresh().getDays();
        RefreshToken token = new RefreshToken();
        token.setAccountId(accountId);
        token.setUserId(userId);
        token.setTokenHash(hashToken(refreshTokenPlain));
        token.setIssuedAt(Instant.now());
        token.setExpiresAt(Instant.now().plusSeconds(days * 24L * 3600));
        refreshTokenRepository.save(token);
    }

    private String hashToken(String token) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(token.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }

    private String resolveRole(UUID userId) {
        List<UserRole> roles = userRoleRepository.findByUserId(userId);
        return roles.isEmpty() ? "tenant" : normalizeRole(roles.get(0).getRole());
    }

    private String normalizeRole(String role) {
        if (role == null || role.isBlank()) return "tenant";
        String r = role.trim().toLowerCase();
        if (r.equals("property_manager") || r.equals("pm")) return "manager";
        if (r.equals("co_tenant") || r.equals("cotenant")) return "tenant";
        return r;
    }
}
