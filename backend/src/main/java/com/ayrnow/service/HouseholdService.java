package com.ayrnow.service;

import com.ayrnow.domain.HouseholdMember;
import com.ayrnow.domain.Property;
import com.ayrnow.domain.Unit;
import com.ayrnow.dto.HouseholdMemberResponse;
import com.ayrnow.dto.InviteHouseholdMemberRequest;
import com.ayrnow.error.ResourceNotFoundException;
import com.ayrnow.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class HouseholdService {

    private final HouseholdMemberRepository memberRepository;
    private final UnitRepository unitRepository;
    private final PropertyRepository propertyRepository;
    private final MembershipRepository membershipRepository;
    private final AccessControlService accessControl;
    private final NotificationService notificationService;

    public HouseholdService(HouseholdMemberRepository memberRepository, UnitRepository unitRepository,
                           PropertyRepository propertyRepository, MembershipRepository membershipRepository,
                           AccessControlService accessControl, NotificationService notificationService) {
        this.memberRepository = memberRepository;
        this.unitRepository = unitRepository;
        this.propertyRepository = propertyRepository;
        this.membershipRepository = membershipRepository;
        this.accessControl = accessControl;
        this.notificationService = notificationService;
    }

    public List<HouseholdMemberResponse> listMembers(UUID unitId, UUID userId, String role) {
        accessControl.ensureCanAccessUnit(userId, role, unitId);
        return memberRepository.findByUnitIdOrderByCreatedAtAsc(unitId).stream()
                .map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, String> inviteMember(InviteHouseholdMemberRequest req, UUID userId, String role) {
        UUID unitId = req.getUnitId();
        if (unitId == null) throw new IllegalArgumentException("unitId required");
        accessControl.ensureCanAccessUnit(userId, role, unitId);

        if ("tenant".equalsIgnoreCase(role)) {
            if (!List.of("coTenant", "familyMember").contains(req.getRole())) {
                throw new org.springframework.security.access.AccessDeniedException("Tenant can only invite coTenant or familyMember");
            }
        } else if ("landlord".equalsIgnoreCase(role)) {
            if (!List.of("coTenant", "familyMember", "landlordAssistant").contains(req.getRole())) {
                throw new IllegalArgumentException("Invalid role for landlord invite");
            }
        }

        if (memberRepository.findByUnitIdAndEmail(unitId, req.getEmail()).isPresent()) {
            throw new IllegalArgumentException("Member with this email already exists in unit");
        }

        HouseholdMember m = new HouseholdMember();
        m.setId(UUID.randomUUID());
        m.setUnitId(unitId);
        m.setName(req.getName());
        m.setEmail(req.getEmail());
        m.setPhone(req.getPhone());
        m.setRole(req.getRole());
        m.setStatus("invited");
        String code = "INV-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        m.setInviteCode(code);
        m.setCreatedAt(Instant.now());
        m = memberRepository.save(m);

        var memberships = membershipRepository.findByUnitId(unitId);
        for (var mb : memberships) {
            Map<String, String> params = new HashMap<>();
            params.put("unitId", unitId.toString());
            params.put("targetRole", "tenant");
            notificationService.notifyUser(mb.getUserId(), "householdInvite", "New household invite",
                    req.getName() + " was invited to the unit.", "/T-50", params);
        }
        return Map.of("memberId", m.getId().toString(), "inviteCode", code);
    }

    @Transactional
    public void deactivateMember(UUID memberId, UUID userId, String role) {
        HouseholdMember m = memberRepository.findById(memberId).orElseThrow(() -> new ResourceNotFoundException("Member not found"));
        accessControl.ensureCanAccessUnit(userId, role, m.getUnitId());

        boolean canDeactivate = false;
        if ("landlord".equalsIgnoreCase(role)) {
            Unit u = unitRepository.findById(m.getUnitId()).orElseThrow();
            Property p = propertyRepository.findById(u.getPropertyId()).orElseThrow();
            canDeactivate = p.getOwnerUserId() != null && p.getOwnerUserId().equals(userId);
        } else if ("tenant".equalsIgnoreCase(role)) {
            Optional<com.ayrnow.domain.Membership> mem = membershipRepository.findByUnitIdAndUserId(m.getUnitId(), userId);
            canDeactivate = mem.isPresent() && "tenant".equalsIgnoreCase(mem.get().getRole());
        }
        if (!canDeactivate) throw new org.springframework.security.access.AccessDeniedException("Cannot deactivate");

        m.setStatus("inactive");
        memberRepository.save(m);

        var memberships = membershipRepository.findByUnitId(m.getUnitId());
        for (var mb : memberships) {
            Map<String, String> params = new HashMap<>();
            params.put("unitId", m.getUnitId().toString());
            notificationService.notifyUser(mb.getUserId(), "householdDeactivated", "Household member deactivated",
                    m.getName() + " was deactivated.", "/T-50", params);
        }
    }

    private HouseholdMemberResponse toResponse(HouseholdMember m) {
        return new HouseholdMemberResponse(
                m.getId().toString(),
                m.getUnitId().toString(),
                m.getName(),
                m.getEmail(),
                m.getPhone(),
                m.getRole(),
                m.getStatus(),
                m.getCreatedAt());
    }
}
