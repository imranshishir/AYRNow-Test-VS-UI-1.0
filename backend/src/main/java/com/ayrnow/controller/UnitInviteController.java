package com.ayrnow.controller;

import com.ayrnow.dto.CreateUnitInviteRequest;
import com.ayrnow.domain.UnitInvite;
import com.ayrnow.repository.UnitInviteRepository;
import com.ayrnow.repository.UserRepository;
import com.ayrnow.service.AccessControlService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/units")
public class UnitInviteController {

    private final UnitInviteRepository unitInviteRepository;
    private final UserRepository userRepository;
    private final AccessControlService accessControlService;

    public UnitInviteController(UnitInviteRepository unitInviteRepository,
                                UserRepository userRepository,
                                AccessControlService accessControlService) {
        this.unitInviteRepository = unitInviteRepository;
        this.userRepository = userRepository;
        this.accessControlService = accessControlService;
    }

    @PostMapping("/{unitId}/invites")
    public Map<String, Object> createInvite(@PathVariable UUID unitId,
                                            @Valid @RequestBody CreateUnitInviteRequest request,
                                            Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");

        // Ensure caller can access this unit (landlord or tenant member).
        accessControlService.ensureCanAccessUnit(userId, role, unitId);

        UnitInvite invite = new UnitInvite();
        invite.setUnitId(unitId);
        invite.setEmail(request.getEmail());
        invite.setToken(UUID.randomUUID().toString().replace("-", ""));
        invite.setStatus("PENDING");
        invite.setCreatedAt(Instant.now());

        UnitInvite saved = unitInviteRepository.save(invite);

        return Map.of(
                "id", saved.getId().toString(),
                "token", saved.getToken(),
                "email", saved.getEmail(),
                "unitId", saved.getUnitId().toString(),
                "status", saved.getStatus()
        );
    }
}
