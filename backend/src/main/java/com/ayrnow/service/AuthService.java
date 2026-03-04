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

    public AuthService(UserRepository userRepository, JwtService jwtService) {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
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
        return new LoginResponse(token, user.getRole(), user.getId().toString(), user.getEmail());
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
