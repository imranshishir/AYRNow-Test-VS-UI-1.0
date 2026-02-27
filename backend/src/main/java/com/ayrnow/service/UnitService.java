package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.Property;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.domain.repository.LeaseRepository;
import com.ayrnow.domain.repository.PropertyRepository;
import com.ayrnow.domain.repository.UnitRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class UnitService {

    private static final List<String> VALID_UNIT_STATUSES = List.of("vacant", "occupied", "maintenance", "reserved");

    private final UnitRepository unitRepository;
    private final PropertyRepository propertyRepository;
    private final LeaseRepository leaseRepository;

    public UnitService(UnitRepository unitRepository, PropertyRepository propertyRepository, LeaseRepository leaseRepository) {
        this.unitRepository = unitRepository;
        this.propertyRepository = propertyRepository;
        this.leaseRepository = leaseRepository;
    }

    public List<Unit> listByProperty(UUID accountId, UUID propertyId) {
        if (!propertyBelongsToAccount(accountId, propertyId)) {
            return List.of();
        }
        return unitRepository.findByAccountIdAndPropertyIdOrderByUnitLabel(accountId, propertyId);
    }

    public Unit getById(UUID accountId, UUID unitId) {
        return unitRepository.findByAccountIdAndId(accountId, unitId)
                .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
    }

    @Transactional
    public Unit create(UUID accountId, UUID propertyId, String unitLabel, String status) {
        Property p = propertyRepository.findByAccountIdAndId(accountId, propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found"));
        String resolvedStatus = resolveStatus(status);
        Unit u = new Unit();
        u.setAccountId(accountId);
        u.setPropertyId(propertyId);
        u.setUnitLabel(unitLabel);
        u.setStatus(resolvedStatus);
        return unitRepository.save(u);
    }

    @Transactional
    public Unit patch(UUID accountId, UUID unitId, String unitLabel, String status) {
        Unit u = getById(accountId, unitId);
        if (unitLabel != null) {
            if (unitLabel.isBlank()) {
                throw new IllegalArgumentException("unitLabel must not be empty");
            }
            u.setUnitLabel(unitLabel.trim());
        }
        if (status != null) {
            u.setStatus(validateAndResolveStatus(status));
        }
        return unitRepository.save(u);
    }

    @Transactional
    public void delete(UUID accountId, UUID unitId) {
        Unit u = getById(accountId, unitId);
        if (!leaseRepository.findActiveByUnitId(unitId).isEmpty()) {
            throw new ConflictException("Cannot delete unit: has an active lease");
        }
        unitRepository.delete(u);
    }

    public boolean propertyBelongsToAccount(UUID accountId, UUID propertyId) {
        return propertyRepository.findByAccountIdAndId(accountId, propertyId).isPresent();
    }

    private String resolveStatus(String status) {
        if (status == null || status.isBlank()) {
            return "vacant";
        }
        return validateAndResolveStatus(status.trim());
    }

    private String validateAndResolveStatus(String status) {
        if (!VALID_UNIT_STATUSES.contains(status.toLowerCase())) {
            throw new IllegalArgumentException("status must be one of: vacant, occupied, maintenance, reserved");
        }
        return status.toLowerCase();
    }
}
