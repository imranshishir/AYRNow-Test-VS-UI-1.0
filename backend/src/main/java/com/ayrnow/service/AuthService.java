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

    public AuthService(UserRepository userRepository, JwtService jwtService, RefreshTokenService refreshTokenService) {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.refreshTokenService = refreshTokenService;
    }

    @Transactional
    public LoginResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail())
                .orElseGet(() -> createUser(req.getEmail(), req.getRole(), req.getName()));
        if (user.getRole() == null || !user.getRole().equalsIgnoreCase(req.getRole())) {
            user.setRole(req.getRole());
            if (req.getName() != null && !req.getName().isBlank()) user.setName(req.getName());
            user = userRepository.save(user);
        } else if (req.getName() != null && !req.getName().isBlank()) {
            user.setName(req.getName());
            user = userRepository.save(user);
        }
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

    private User createUser(String email, String role, String name) {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setEmail(email);
        user.setName(name != null && !name.isBlank() ? name : email.split("@")[0]);
        user.setRole(role);
        user.setCreatedAt(Instant.now());
        return userRepository.save(user);
    }
}
