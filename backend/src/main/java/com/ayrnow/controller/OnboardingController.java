package com.ayrnow.controller;

import com.ayrnow.dto.AssignTenantRequest;
import com.ayrnow.dto.OnboardingPropertyRequest;
import com.ayrnow.repository.UserRepository;
import com.ayrnow.service.OnboardingService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/onboarding")
public class OnboardingController {

    private final OnboardingService onboardingService;
    private final UserRepository userRepository;

    public OnboardingController(OnboardingService onboardingService, UserRepository userRepository) {
        this.onboardingService = onboardingService;
        this.userRepository = userRepository;
    }

    @PostMapping("/property")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createProperty(@Valid @RequestBody OnboardingPropertyRequest request, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return onboardingService.createProperty(request, userId, role);
    }

    @PostMapping("/unit/{unitId}/assign-tenant")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, String> assignTenant(@PathVariable UUID unitId, @Valid @RequestBody AssignTenantRequest request, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return onboardingService.assignTenant(unitId, request, userId, role);
    }
}
