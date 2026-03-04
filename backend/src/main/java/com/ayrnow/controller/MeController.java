package com.ayrnow.controller;

import com.ayrnow.domain.User;
import com.ayrnow.dto.MeResponse;
import com.ayrnow.error.ResourceNotFoundException;
import com.ayrnow.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/v1")
public class MeController {

    private final UserRepository userRepository;

    public MeController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/me")
    public MeResponse me(Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        User user = userRepository.findById(userId).orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return new MeResponse(user.getId().toString(), user.getEmail(), user.getName(), user.getRole());
    }
}
