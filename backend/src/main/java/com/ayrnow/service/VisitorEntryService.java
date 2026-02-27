package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.domain.entity.VisitorEntry;
import com.ayrnow.domain.repository.PropertyRepository;
import com.ayrnow.domain.repository.UnitRepository;
import com.ayrnow.domain.repository.VisitorEntryRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

@Service
public class VisitorEntryService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");
    private static final Set<String> CREATE_ROLES = Set.of("landlord", "manager", "owner", "security_guard");
    private static final Set<String> LIST_ROLES = Set.of("landlord", "manager", "owner", "security_guard");

    private final VisitorEntryRepository visitorRepository;
    private final PropertySecuritySettingsService settingsService;
    private final PropertyRepository propertyRepository;
    private final UnitRepository unitRepository;

    public VisitorEntryService(VisitorEntryRepository visitorRepository,
                               PropertySecuritySettingsService settingsService,
                               PropertyRepository propertyRepository,
                               UnitRepository unitRepository) {
        this.visitorRepository = visitorRepository;
        this.settingsService = settingsService;
        this.propertyRepository = propertyRepository;
        this.unitRepository = unitRepository;
    }

    private boolean canCreate(String role) {
        return CREATE_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    private boolean canList(String role) {
        return LIST_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    private boolean canApproveDeny(String role) {
        return STAFF_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    public Page<VisitorEntry> list(UUID accountId, UUID propertyId, UUID unitId, String status,
                                  int page, int size, String principalRole) {
        if (!canList(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        if (propertyId != null) {
            propertyRepository.findByAccountIdAndId(accountId, propertyId)
                    .orElseThrow(() -> new ResourceNotFoundException("Property not found"));
        }
        if (unitId != null) {
            unitRepository.findByAccountIdAndId(accountId, unitId)
                    .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
        }
        return visitorRepository.findByAccountWithFilters(
                accountId, propertyId, unitId, status,
                PageRequest.of(page, Math.min(size, 100)));
    }

    public VisitorEntry getById(UUID accountId, UUID visitorId, String principalRole) {
        if (!canList(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        return visitorRepository.findByAccountIdAndId(accountId, visitorId)
                .orElseThrow(() -> new ResourceNotFoundException("Visitor entry not found"));
    }

    @Transactional
    public VisitorEntry create(UUID accountId, UUID principalUserId, String principalRole,
                               UUID propertyId, UUID unitId, String visitorName, String visitorPhone, String purpose) {
        if (!canCreate(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        propertyRepository.findByAccountIdAndId(accountId, propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found"));
        if (unitId != null) {
            Unit unit = unitRepository.findByAccountIdAndId(accountId, unitId)
                    .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
            if (!unit.getPropertyId().equals(propertyId)) {
                throw new ConflictException("Unit does not belong to property");
            }
        }
        boolean approvalRequired = settingsService.isApprovalRequired(accountId, propertyId);
        String initialStatus = approvalRequired ? "pending" : "logged";

        VisitorEntry v = new VisitorEntry();
        v.setAccountId(accountId);
        v.setPropertyId(propertyId);
        v.setUnitId(unitId);
        v.setCreatedByUserId(principalUserId);
        v.setVisitorName(visitorName.trim());
        v.setVisitorPhone(visitorPhone != null && !visitorPhone.isBlank() ? visitorPhone.trim() : null);
        v.setPurpose(purpose != null && !purpose.isBlank() ? purpose.trim() : null);
        v.setStatus(initialStatus);
        return visitorRepository.save(v);
    }

    @Transactional
    public VisitorEntry approve(UUID accountId, UUID visitorId, UUID principalUserId, String principalRole) {
        if (!canApproveDeny(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        VisitorEntry v = visitorRepository.findByAccountIdAndId(accountId, visitorId)
                .orElseThrow(() -> new ResourceNotFoundException("Visitor entry not found"));
        if (!"pending".equals(v.getStatus())) {
            throw new ConflictException("Can only approve a pending visitor entry");
        }
        v.setStatus("approved");
        v.setApprovedByUserId(principalUserId);
        v.setApprovedAt(Instant.now());
        v.setDeniedByUserId(null);
        v.setDeniedAt(null);
        return visitorRepository.save(v);
    }

    @Transactional
    public VisitorEntry deny(UUID accountId, UUID visitorId, UUID principalUserId, String principalRole) {
        if (!canApproveDeny(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        VisitorEntry v = visitorRepository.findByAccountIdAndId(accountId, visitorId)
                .orElseThrow(() -> new ResourceNotFoundException("Visitor entry not found"));
        if (!"pending".equals(v.getStatus())) {
            throw new ConflictException("Can only deny a pending visitor entry");
        }
        v.setStatus("denied");
        v.setDeniedByUserId(principalUserId);
        v.setDeniedAt(Instant.now());
        v.setApprovedByUserId(null);
        v.setApprovedAt(null);
        return visitorRepository.save(v);
    }
}
