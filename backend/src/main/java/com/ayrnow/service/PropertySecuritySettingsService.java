package com.ayrnow.service;

import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.PropertySecuritySettings;
import com.ayrnow.domain.repository.PropertyRepository;
import com.ayrnow.domain.repository.PropertySecuritySettingsRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;
import java.util.UUID;

@Service
public class PropertySecuritySettingsService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");
    private static final Set<String> READ_ROLES = Set.of("landlord", "manager", "owner", "security_guard");

    private final PropertySecuritySettingsRepository settingsRepository;
    private final PropertyRepository propertyRepository;

    public PropertySecuritySettingsService(PropertySecuritySettingsRepository settingsRepository,
                                          PropertyRepository propertyRepository) {
        this.settingsRepository = settingsRepository;
        this.propertyRepository = propertyRepository;
    }

    private boolean canRead(String role) {
        return READ_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    private boolean canWrite(String role) {
        return STAFF_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    public PropertySecuritySettings get(UUID accountId, UUID propertyId, String principalRole) {
        if (!canRead(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        propertyRepository.findByAccountIdAndId(accountId, propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found"));
        return settingsRepository.findByAccountIdAndPropertyId(accountId, propertyId)
                .orElse(null);
    }

    @Transactional
    public PropertySecuritySettings patch(UUID accountId, UUID propertyId, String principalRole, Boolean approvalRequired) {
        if (!canWrite(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        propertyRepository.findByAccountIdAndId(accountId, propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found"));
        PropertySecuritySettings s = settingsRepository.findByAccountIdAndPropertyId(accountId, propertyId)
                .orElseGet(() -> {
                    PropertySecuritySettings newSettings = new PropertySecuritySettings();
                    newSettings.setPropertyId(propertyId);
                    newSettings.setAccountId(accountId);
                    return settingsRepository.save(newSettings);
                });
        if (approvalRequired != null) {
            s.setApprovalRequired(approvalRequired);
            s = settingsRepository.save(s);
        }
        return s;
    }

    public boolean isApprovalRequired(UUID accountId, UUID propertyId) {
        return settingsRepository.findByAccountIdAndPropertyId(accountId, propertyId)
                .map(PropertySecuritySettings::isApprovalRequired)
                .orElse(false);
    }
}
