package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.PropertySecuritySettings;

import java.util.UUID;

public record SecuritySettingsResponse(
        UUID propertyId,
        boolean approvalRequired
) {
    public static SecuritySettingsResponse from(PropertySecuritySettings s) {
        return new SecuritySettingsResponse(s.getPropertyId(), s.isApprovalRequired());
    }

    public static SecuritySettingsResponse defaults(UUID propertyId) {
        return new SecuritySettingsResponse(propertyId, false);
    }
}
