package com.ayrnow.service;

import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.domain.entity.UnitMember;
import com.ayrnow.domain.repository.LeaseRepository;
import com.ayrnow.domain.repository.UnitMemberRepository;
import com.ayrnow.domain.repository.UnitRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import org.springframework.data.domain.PageRequest;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class UnitMemberService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");
    private static final Set<String> TENANT_LIKE_ROLES = Set.of("tenant", "family", "cotenant", "co_tenant");

    private final UnitMemberRepository unitMemberRepository;
    private final UnitRepository unitRepository;
    private final LeaseRepository leaseRepository;

    public UnitMemberService(UnitMemberRepository unitMemberRepository, UnitRepository unitRepository, LeaseRepository leaseRepository) {
        this.unitMemberRepository = unitMemberRepository;
        this.unitRepository = unitRepository;
        this.leaseRepository = leaseRepository;
    }

    public List<UnitMember> getMembers(UUID accountId, UUID unitId, UUID principalUserId, String principalRole) {
        Unit unit = unitRepository.findByAccountIdAndId(accountId, unitId)
                .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));

        List<UnitMember> members = unitMemberRepository.findByAccountIdAndUnitIdOrderByAddedAtAsc(accountId, unitId);
        Set<UUID> memberUserIds = members.stream().map(UnitMember::getUserId).collect(Collectors.toSet());

        if (STAFF_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            return members;
        }
        if (TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            if (memberUserIds.contains(principalUserId)) {
                return members;
            }
            boolean isPrimaryTenant = leaseRepository.findActiveByUnitId(unitId).stream()
                    .anyMatch(l -> l.getTenantUserId().equals(principalUserId));
            if (!isPrimaryTenant) {
                throw new AccessDeniedException("Forbidden");
            }
            return members;
        }
        throw new AccessDeniedException("Forbidden");
    }

    /**
     * Returns unit IDs and property IDs the user belongs to (unit_members or active lease tenant).
     * Used for tenant post visibility.
     */
    public TenantScope getTenantScope(UUID accountId, UUID userId) {
        Set<UUID> unitIds = new HashSet<>();
        Set<UUID> propertyIds = new HashSet<>();
        for (UnitMember m : unitMemberRepository.findByAccountIdAndUserId(accountId, userId)) {
            unitIds.add(m.getUnitId());
            unitRepository.findByAccountIdAndId(accountId, m.getUnitId()).ifPresent(u -> propertyIds.add(u.getPropertyId()));
        }
        for (var lease : leaseRepository.findActiveByAccountAndTenant(accountId, userId, PageRequest.of(0, 100))) {
            unitIds.add(lease.getUnitId());
            unitRepository.findByAccountIdAndId(accountId, lease.getUnitId()).ifPresent(u -> propertyIds.add(u.getPropertyId()));
        }
        return new TenantScope(unitIds, propertyIds);
    }

    public record TenantScope(Set<UUID> unitIds, Set<UUID> propertyIds) {}

    /**
     * Returns true if user is in unit_members or is primary tenant of unit's active lease.
     */
    public boolean userBelongsToUnit(UUID accountId, UUID unitId, UUID userId) {
        if (unitMemberRepository.existsByAccountIdAndUnitIdAndUserId(accountId, unitId, userId)) {
            return true;
        }
        return leaseRepository.findActiveByUnitId(unitId).stream()
                .anyMatch(l -> l.getTenantUserId().equals(userId));
    }
}
