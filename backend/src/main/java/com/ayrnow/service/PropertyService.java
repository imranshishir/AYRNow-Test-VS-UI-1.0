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
public class PropertyService {

    private final PropertyRepository propertyRepository;
    private final UnitRepository unitRepository;
    private final LeaseRepository leaseRepository;

    public PropertyService(PropertyRepository propertyRepository, UnitRepository unitRepository, LeaseRepository leaseRepository) {
        this.propertyRepository = propertyRepository;
        this.unitRepository = unitRepository;
        this.leaseRepository = leaseRepository;
    }

    public List<Property> listByAccount(UUID accountId) {
        return propertyRepository.findByAccountIdOrderByCreatedAtDesc(accountId);
    }

    public Property getById(UUID accountId, UUID propertyId) {
        return propertyRepository.findByAccountIdAndId(accountId, propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found"));
    }

    @Transactional
    public Property create(UUID accountId, String name, String address1, String city, String state, String postalCode) {
        Property p = new Property();
        p.setAccountId(accountId);
        p.setName(name);
        p.setAddress1(address1);
        p.setCity(city);
        p.setState(state);
        p.setPostalCode(postalCode);
        return propertyRepository.save(p);
    }

    @Transactional
    public Property patch(UUID accountId, UUID propertyId, String name, String address1, String city, String state, String postalCode) {
        Property p = getById(accountId, propertyId);
        if (name != null) {
            if (name.isBlank()) {
                throw new IllegalArgumentException("name must not be empty");
            }
            p.setName(name.trim());
        }
        if (address1 != null) p.setAddress1(address1);
        if (city != null) p.setCity(city);
        if (state != null) p.setState(state);
        if (postalCode != null) p.setPostalCode(postalCode);
        return propertyRepository.save(p);
    }

    @Transactional
    public void delete(UUID accountId, UUID propertyId) {
        Property p = getById(accountId, propertyId);
        List<Unit> units = unitRepository.findByAccountIdAndPropertyIdOrderByUnitLabel(accountId, propertyId);
        for (Unit u : units) {
            if (!leaseRepository.findActiveByUnitId(u.getId()).isEmpty()) {
                throw new ConflictException("Cannot delete property: unit has an active lease");
            }
        }
        propertyRepository.delete(p);
    }
}
