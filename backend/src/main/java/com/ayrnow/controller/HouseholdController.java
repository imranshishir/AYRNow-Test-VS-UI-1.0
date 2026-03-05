package com.ayrnow.controller;

import com.ayrnow.dto.HouseholdMemberResponse;
import com.ayrnow.dto.InviteHouseholdMemberRequest;
import com.ayrnow.repository.UserRepository;
import com.ayrnow.service.HouseholdService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/household")
public class HouseholdController {

    private final HouseholdService householdService;
    private final UserRepository userRepository;

    public HouseholdController(HouseholdService householdService, UserRepository userRepository) {
        this.householdService = householdService;
        this.userRepository = userRepository;
    }

    @GetMapping("/members")
    public List<HouseholdMemberResponse> listMembers(@RequestParam UUID unitId, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return householdService.listMembers(unitId, userId, role);
    }

    @PostMapping("/members/invite")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, String> inviteMember(@Valid @RequestBody InviteHouseholdMemberRequest request, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return householdService.inviteMember(request, userId, role);
    }

    @PostMapping("/members/{memberId}/deactivate")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deactivateMember(@PathVariable UUID memberId, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        householdService.deactivateMember(memberId, userId, role);
    }
}
