package com.ayrnow.controller;

import com.ayrnow.dto.PropertyResponse;
import com.ayrnow.dto.UnitResponse;
import com.ayrnow.repository.UserRepository;
import com.ayrnow.service.PropertyService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/properties")
public class PropertyController {

    private final PropertyService propertyService;
    private final UserRepository userRepository;

    public PropertyController(PropertyService propertyService, UserRepository userRepository) {
        this.propertyService = propertyService;
        this.userRepository = userRepository;
    }

    @GetMapping
    public List<PropertyResponse> list(Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return propertyService.listProperties(userId, role);
    }

    @GetMapping("/{propertyId}/units")
    public List<UnitResponse> listUnits(@PathVariable UUID propertyId, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return propertyService.listUnits(userId, role, propertyId);
    }
}
