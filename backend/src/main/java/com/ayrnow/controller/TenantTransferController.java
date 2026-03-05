package com.ayrnow.controller;

import com.ayrnow.dto.*;
import com.ayrnow.repository.UserRepository;
import com.ayrnow.service.TenantTransferService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/tenant-transfer")
public class TenantTransferController {

    private final TenantTransferService tenantTransferService;
    private final UserRepository userRepository;

    public TenantTransferController(TenantTransferService tenantTransferService, UserRepository userRepository) {
        this.tenantTransferService = tenantTransferService;
        this.userRepository = userRepository;
    }

    @GetMapping("/profile")
    public TenantProfileResponse getProfile(Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return tenantTransferService.getMyProfile(userId, role);
    }

    @GetMapping("/my-request")
    public org.springframework.http.ResponseEntity<TransferRequestResponse> getMyRequest(Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        TransferRequestResponse r = tenantTransferService.getMyActiveRequest(userId, role);
        if (r == null) return org.springframework.http.ResponseEntity.noContent().build();
        return org.springframework.http.ResponseEntity.ok(r);
    }

    @PostMapping("/requests")
    @ResponseStatus(HttpStatus.CREATED)
    public TransferRequestResponse createRequest(@Valid @RequestBody CreateTransferRequestRequest request, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return tenantTransferService.createRequest(request, userId, role);
    }

    @GetMapping("/inbox")
    public List<TransferRequestResponse> listInbox(@RequestParam(required = false) String status, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("landlord");
        return tenantTransferService.listForLandlord(status, userId, role);
    }

    @PostMapping("/requests/{id}/decision")
    public TransferRequestResponse decide(@PathVariable UUID id, @Valid @RequestBody TransferDecisionRequest request, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("landlord");
        return tenantTransferService.decide(id, request, userId, role);
    }
}
