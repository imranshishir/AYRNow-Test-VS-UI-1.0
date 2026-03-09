package com.ayrnow.service;

import com.ayrnow.domain.Property;
import com.ayrnow.domain.Unit;
import com.ayrnow.dto.CreatePropertyRequest;
import com.ayrnow.dto.PropertyResponse;
import com.ayrnow.dto.UnitResponse;
import com.ayrnow.repository.PropertyRepository;
import com.ayrnow.repository.UnitRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class PropertyService {

    private final PropertyRepository propertyRepository;
    private final UnitRepository unitRepository;
    private final AccessControlService accessControlService;

    public PropertyService(PropertyRepository propertyRepository, UnitRepository unitRepository, AccessControlService accessControlService) {
        this.propertyRepository = propertyRepository;
        this.unitRepository = unitRepository;
        this.accessControlService = accessControlService;
    }

    public List<PropertyResponse> listProperties(UUID userId, String role) {
        Set<UUID> ids = accessControlService.getAccessiblePropertyIds(userId, role);
        return propertyRepository.findAllById(ids).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<UnitResponse> listUnits(UUID userId, String role, UUID propertyId) {
        accessControlService.ensureCanAccessProperty(userId, role, propertyId);
        Set<UUID> accessibleUnitIds = accessControlService.getAccessibleUnitIdsForProperty(userId, role, propertyId);
        return unitRepository.findByPropertyId(propertyId).stream()
                .filter(u -> accessibleUnitIds.contains(u.getId()))
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public PropertyResponse createProperty(UUID userId, String role, CreatePropertyRequest request) {
        if (!"landlord".equalsIgnoreCase(role)) {
            throw new AccessDeniedException("Only landlords can create properties");
        }
        String address = buildAddress(request.getAddress1(), request.getCity(), request.getState(), request.getPostalCode());
        Property p = new Property();
        p.setOwnerUserId(userId);
        p.setName(request.getName() != null ? request.getName().trim() : "");
        p.setAddress(address);
        p.setCreatedAt(Instant.now());
        p = propertyRepository.save(p);
        return toResponse(p);
    }

    private static String buildAddress(String address1, String city, String state, String postalCode) {
        List<String> parts = new ArrayList<>();
        if (address1 != null && !address1.isBlank()) parts.add(address1.trim());
        if (city != null && !city.isBlank()) parts.add(city.trim());
        if (state != null && !state.isBlank()) parts.add(state.trim());
        if (postalCode != null && !postalCode.isBlank()) parts.add(postalCode.trim());
        return String.join(", ", parts);
    }

    private PropertyResponse toResponse(Property p) {
        return new PropertyResponse(p.getId().toString(), p.getName(), p.getAddress());
    }

    private UnitResponse toResponse(Unit u) {
        return new UnitResponse(u.getId().toString(), u.getLabel(), u.getPropertyId().toString());
    }
}
