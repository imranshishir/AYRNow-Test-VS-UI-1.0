package com.ayrnow.service;

import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.api.dto.LeaseTenantResponse;
import com.ayrnow.domain.entity.AppUser;
import com.ayrnow.domain.entity.Lease;
import com.ayrnow.domain.entity.LeaseTenant;
import com.ayrnow.domain.repository.AppUserRepository;
import com.ayrnow.domain.repository.LeaseRepository;
import com.ayrnow.domain.repository.LeaseTenantRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class LeaseTenantService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");
    private static final Set<String> TENANT_LIKE_ROLES = Set.of("tenant", "family", "cotenant", "co_tenant");

    private final LeaseRepository leaseRepository;
    private final LeaseTenantRepository leaseTenantRepository;
    private final AppUserRepository appUserRepository;

    public LeaseTenantService(LeaseRepository leaseRepository, LeaseTenantRepository leaseTenantRepository, AppUserRepository appUserRepository) {
        this.leaseRepository = leaseRepository;
        this.leaseTenantRepository = leaseTenantRepository;
        this.appUserRepository = appUserRepository;
    }

    public List<LeaseTenantResponse> getTenants(UUID accountId, UUID leaseId, UUID principalUserId, String principalRole) {
        Lease lease = leaseRepository.findByAccountIdAndId(accountId, leaseId)
                .orElseThrow(() -> new ResourceNotFoundException("Lease not found"));

        Set<UUID> tenantUserIds = new LinkedHashSet<>();
        tenantUserIds.add(lease.getTenantUserId());
        leaseTenantRepository.findByAccountIdAndLeaseIdOrderByAddedAtAsc(accountId, leaseId)
                .stream()
                .map(LeaseTenant::getUserId)
                .forEach(tenantUserIds::add);

        if (STAFF_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            return buildResponses(accountId, lease.getTenantUserId(), new ArrayList<>(tenantUserIds));
        }
        if (TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            if (!tenantUserIds.contains(principalUserId)) {
                throw new AccessDeniedException("Forbidden");
            }
            return buildResponses(accountId, lease.getTenantUserId(), new ArrayList<>(tenantUserIds));
        }
        throw new AccessDeniedException("Forbidden");
    }

    /**
     * Returns true if user is primary tenant or in lease_tenants for this lease.
     */
    public boolean userBelongsToLease(UUID accountId, UUID leaseId, UUID userId) {
        Lease lease = leaseRepository.findByAccountIdAndId(accountId, leaseId).orElse(null);
        if (lease == null) return false;
        if (lease.getTenantUserId().equals(userId)) return true;
        return leaseTenantRepository.findByAccountIdAndLeaseIdOrderByAddedAtAsc(accountId, leaseId)
                .stream()
                .anyMatch(lt -> lt.getUserId().equals(userId));
    }

    private List<LeaseTenantResponse> buildResponses(UUID accountId, UUID primaryTenantId, List<UUID> userIds) {
        Map<UUID, AppUser> userMap = userIds.stream()
                .distinct()
                .map(id -> appUserRepository.findByAccountIdAndId(accountId, id))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toMap(AppUser::getId, u -> u));

        return userIds.stream()
                .map(userId -> {
                    String role = userId.equals(primaryTenantId) ? "tenant" : "resident";
                    AppUser u = userMap.get(userId);
                    return new LeaseTenantResponse(
                            userId,
                            role,
                            u != null ? u.getDisplayName() : null,
                            u != null ? u.getEmail() : null
                    );
                })
                .toList();
    }
}
