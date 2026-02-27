package com.ayrnow.service;

import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.api.dto.BalanceResponse;
import com.ayrnow.domain.entity.Lease;
import com.ayrnow.domain.entity.LedgerEntry;
import com.ayrnow.domain.repository.LedgerEntryRepository;
import com.ayrnow.domain.repository.LeaseRepository;
import com.ayrnow.domain.repository.UnitRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class BalanceService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");
    private static final Set<String> TENANT_LIKE_ROLES = Set.of("tenant", "family", "cotenant", "co_tenant");

    private final LedgerEntryRepository ledgerRepository;
    private final UnitRepository unitRepository;
    private final LeaseRepository leaseRepository;
    private final UnitMemberService unitMemberService;
    private final LeaseTenantService leaseTenantService;

    public BalanceService(LedgerEntryRepository ledgerRepository,
                          UnitRepository unitRepository,
                          LeaseRepository leaseRepository,
                          UnitMemberService unitMemberService,
                          LeaseTenantService leaseTenantService) {
        this.ledgerRepository = ledgerRepository;
        this.unitRepository = unitRepository;
        this.leaseRepository = leaseRepository;
        this.unitMemberService = unitMemberService;
        this.leaseTenantService = leaseTenantService;
    }

    private boolean isStaff(String role) {
        return STAFF_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    public BalanceResponse getUnitBalance(UUID accountId, UUID unitId, LocalDate asOf,
                                          UUID principalUserId, String principalRole) {
        if (!isStaff(principalRole) && !TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            throw new AccessDeniedException("Forbidden");
        }
        if (!isStaff(principalRole)) {
            if (!unitMemberService.userBelongsToUnit(accountId, unitId, principalUserId)) {
                throw new AccessDeniedException("Forbidden");
            }
        }
        unitRepository.findByAccountIdAndId(accountId, unitId)
                .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
        LocalDate asOfDate = asOf != null ? asOf : LocalDate.now();
        List<LedgerEntry> entries = ledgerRepository.findByAccountAndUnitForBalance(accountId, unitId, asOfDate);
        long balanceCents = computeBalance(entries);
        return BalanceResponse.forUnit(unitId, balanceCents, "USD", asOfDate);
    }

    public BalanceResponse getLeaseBalance(UUID accountId, UUID leaseId, LocalDate asOf,
                                           UUID principalUserId, String principalRole) {
        Lease lease = leaseRepository.findByAccountIdAndId(accountId, leaseId)
                .orElseThrow(() -> new ResourceNotFoundException("Lease not found"));
        if (!isStaff(principalRole)) {
            if (!leaseTenantService.userBelongsToLease(accountId, leaseId, principalUserId)) {
                throw new AccessDeniedException("Forbidden");
            }
        }
        LocalDate asOfDate = asOf != null ? asOf : LocalDate.now();
        List<LedgerEntry> entries = ledgerRepository.findByAccountAndLeaseForBalance(accountId, leaseId, asOfDate);
        long balanceCents = computeBalance(entries);
        return BalanceResponse.forLease(lease.getUnitId(), leaseId, balanceCents, "USD", asOfDate);
    }

    private long computeBalance(List<LedgerEntry> entries) {
        long balance = 0;
        for (LedgerEntry e : entries) {
            if ("debit".equals(e.getDirection())) {
                balance += e.getAmountCents();
            } else {
                balance -= e.getAmountCents();
            }
        }
        return balance;
    }
}
