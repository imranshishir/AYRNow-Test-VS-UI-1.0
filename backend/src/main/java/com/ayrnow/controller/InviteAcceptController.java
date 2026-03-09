package com.ayrnow.controller;

import com.ayrnow.domain.UnitInvite;
import com.ayrnow.repository.UnitInviteRepository;
import com.ayrnow.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/invites")
public class InviteAcceptController {

    private final UnitInviteRepository unitInviteRepository;
    private final UserRepository userRepository;

    public InviteAcceptController(UnitInviteRepository unitInviteRepository, UserRepository userRepository) {
        this.unitInviteRepository = unitInviteRepository;
        this.userRepository = userRepository;
    }

    @PostMapping("/accept/{token}")
    public ResponseEntity<Map<String, Object>> accept(@PathVariable String token, Authentication auth) {
        if (token == null || token.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invite token is required");
        }
        UnitInvite invite = unitInviteRepository.findByToken(token)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Invite not found or expired"));
        if (!"PENDING".equalsIgnoreCase(invite.getStatus())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Invite already used or cancelled");
        }
        UUID userId = UUID.fromString(auth.getName());
        invite.setStatus("ACCEPTED");
        unitInviteRepository.save(invite);

        Map<String, Object> body = Map.of(
                "id", invite.getId().toString(),
                "unitId", invite.getUnitId().toString(),
                "status", invite.getStatus(),
                "contactType", "email",
                "contactValue", invite.getEmail() != null ? invite.getEmail() : "",
                "invitedRole", "tenant"
        );
        return ResponseEntity.ok(body);
    }
}
