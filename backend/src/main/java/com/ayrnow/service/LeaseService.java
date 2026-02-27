package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.Lease;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.domain.repository.LeaseRepository;
import com.ayrnow.domain.repository.UnitRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

@Service
public class LeaseService {

    private final LeaseRepository leaseRepository;
    private final UnitRepository unitRepository;

    public LeaseService(LeaseRepository leaseRepository, UnitRepository unitRepository) {
        this.leaseRepository = leaseRepository;
        this.unitRepository = unitRepository;
    }

    public Optional<Lease> getActiveLeaseForUser(UUID accountId, UUID userId) {
        return leaseRepository.findActiveByAccountAndTenant(accountId, userId, PageRequest.of(0, 1))
                .stream()
                .findFirst();
    }

    public Page<Lease> listByAccount(UUID accountId, String status, UUID unitId, int page, int size) {
        return leaseRepository.findByAccountWithFilters(accountId, status, unitId, PageRequest.of(page, Math.min(size, 100)));
    }

    public Lease getById(UUID accountId, UUID leaseId) {
        return leaseRepository.findByAccountIdAndId(accountId, leaseId)
                .orElseThrow(() -> new ResourceNotFoundException("Lease not found"));
    }

    @Transactional
    public Lease create(UUID accountId, UUID unitId, UUID tenantUserId, LocalDate startDate, LocalDate endDate) {
        Unit unit = unitRepository.findByAccountIdAndId(accountId, unitId)
                .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
        if (!leaseRepository.findActiveByUnitId(unitId).isEmpty()) {
            throw new IllegalArgumentException("Unit already has an active lease");
        }
        Lease l = new Lease();
        l.setAccountId(accountId);
        l.setUnitId(unitId);
        l.setTenantUserId(tenantUserId);
        l.setStartDate(startDate);
        l.setEndDate(endDate);
        l.setStatus("active");
        return leaseRepository.save(l);
    }

    @Transactional
    public Lease patch(UUID accountId, UUID leaseId, LocalDate startDate, LocalDate endDate) {
        Lease l = getById(accountId, leaseId);
        if (startDate != null) {
            l.setStartDate(startDate);
        }
        if (endDate != null) {
            l.setEndDate(endDate);
        }
        return leaseRepository.save(l);
    }

    @Transactional
    public Lease end(UUID accountId, UUID leaseId, LocalDate endDate) {
        Lease l = getById(accountId, leaseId);
        if (!"active".equals(l.getStatus())) {
            throw new ConflictException("Lease is not active; cannot end");
        }
        LocalDate effectiveEndDate = endDate != null ? endDate : LocalDate.now();
        l.setEndDate(effectiveEndDate);
        l.setStatus("ended");
        return leaseRepository.save(l);
    }
}
