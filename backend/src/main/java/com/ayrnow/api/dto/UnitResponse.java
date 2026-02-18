package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.Unit;

import java.time.Instant;
import java.util.UUID;

public record UnitResponse(
        UUID id,
        UUID accountId,
        UUID propertyId,
        String unitLabel,
        String status,
        Instant createdAt
) {
    public static UnitResponse from(Unit u) {
        return new UnitResponse(
                u.getId(),
                u.getAccountId(),
                u.getPropertyId(),
                u.getUnitLabel(),
                u.getStatus(),
                u.getCreatedAt()
        );
    }
}
