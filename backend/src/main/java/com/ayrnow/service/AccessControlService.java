package com.ayrnow.service;

import com.ayrnow.domain.Membership;
import com.ayrnow.domain.Property;
import com.ayrnow.domain.Unit;
import com.ayrnow.error.ResourceNotFoundException;
import com.ayrnow.repository.MembershipRepository;
import com.ayrnow.repository.PropertyRepository;
import com.ayrnow.repository.UnitRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class AccessControlService {

    private final PropertyRepository propertyRepository;
    private final UnitRepository unitRepository;
    private final MembershipRepository membershipRepository;

    public AccessControlService(PropertyRepository propertyRepository, UnitRepository unitRepository, MembershipRepository membershipRepository) {
        this.propertyRepository = propertyRepository;
        this.unitRepository = unitRepository;
        this.membershipRepository = membershipRepository;
    }

    public void ensureCanAccessProperty(UUID userId, String role, UUID propertyId) {
        Property p = propertyRepository.findById(propertyId).orElseThrow(() -> new ResourceNotFoundException("Property not found"));
        if ("landlord".equalsIgnoreCase(role)) {
            if (p.getOwnerUserId() == null || !p.getOwnerUserId().equals(userId)) throw new AccessDeniedException("Not your property");
        } else if ("tenant".equalsIgnoreCase(role)) {
            List<Unit> units = unitRepository.findByPropertyId(propertyId);
            boolean hasAccess = units.stream()
                    .anyMatch(u -> membershipRepository.findByUnitIdAndUserId(u.getId(), userId).isPresent());
            if (!hasAccess) throw new AccessDeniedException("Not a member of this property");
        } else {
            throw new AccessDeniedException("Invalid role");
        }
    }

    public void ensureCanAccessUnit(UUID userId, String role, UUID unitId) {
        Unit u = unitRepository.findById(unitId).orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
        if ("landlord".equalsIgnoreCase(role)) {
            Property p = propertyRepository.findById(u.getPropertyId()).orElseThrow();
            if (p.getOwnerUserId() == null || !p.getOwnerUserId().equals(userId)) throw new AccessDeniedException("Not your property");
        } else if ("tenant".equalsIgnoreCase(role)) {
            if (membershipRepository.findByUnitIdAndUserId(unitId, userId).isEmpty())
                throw new AccessDeniedException("Not a member of this unit");
        } else {
            throw new AccessDeniedException("Invalid role");
        }
    }

    public Set<UUID> getAccessiblePropertyIds(UUID userId, String role) {
        if ("landlord".equalsIgnoreCase(role)) {
            return propertyRepository.findByOwnerUserId(userId).stream().map(Property::getId).collect(Collectors.toSet());
        }
        if ("tenant".equalsIgnoreCase(role)) {
            return membershipRepository.findByUserId(userId).stream()
                    .map(Membership::getUnitId)
                    .map(unitRepository::findById)
                    .filter(o -> o.isPresent())
                    .map(o -> o.get().getPropertyId())
                    .collect(Collectors.toSet());
        }
        return Set.of();
    }

    public Set<UUID> getAccessibleUnitIdsForProperty(UUID userId, String role, UUID propertyId) {
        List<Unit> units = unitRepository.findByPropertyId(propertyId);
        if ("landlord".equalsIgnoreCase(role)) {
            Property p = propertyRepository.findById(propertyId).orElseThrow(() -> new ResourceNotFoundException("Property not found"));
            if (p.getOwnerUserId() == null || !p.getOwnerUserId().equals(userId)) return Set.of();
            return units.stream().map(Unit::getId).collect(Collectors.toSet());
        }
        if ("tenant".equalsIgnoreCase(role)) {
            return units.stream()
                    .filter(u -> membershipRepository.findByUnitIdAndUserId(u.getId(), userId).isPresent())
                    .map(Unit::getId)
                    .collect(Collectors.toSet());
        }
        return Set.of();
    }

    public boolean isTenantOfUnit(UUID userId, UUID unitId) {
        return membershipRepository.findByUnitIdAndUserId(unitId, userId).isPresent();
    }

    public java.util.Set<UUID> getAllAccessibleUnitIds(UUID userId, String role) {
        java.util.Set<UUID> result = new java.util.HashSet<>();
        for (UUID propId : getAccessiblePropertyIds(userId, role)) {
            result.addAll(getAccessibleUnitIdsForProperty(userId, role, propId));
        }
        return result;
    }
}
