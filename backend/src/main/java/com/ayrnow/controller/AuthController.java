package com.ayrnow.controller;

import com.ayrnow.dto.LoginRequest;
import com.ayrnow.dto.LoginResponse;
import com.ayrnow.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/refresh")
    public LoginResponse refreshtoken(@Valid @RequestBody com.ayrnow.dto.TokenRefreshRequest request) {
        return authService.refreshToken(request);
    }

    @PostMapping("/register")
    public LoginResponse register(@Valid @RequestBody com.ayrnow.dto.RegisterRequest request) {
        return authService.register(request);
    }
}
