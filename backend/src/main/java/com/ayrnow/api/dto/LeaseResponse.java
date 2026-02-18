package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.Lease;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record LeaseResponse(
        UUID id,
        UUID accountId,
        UUID unitId,
        String status,
        LocalDate startDate,
        LocalDate endDate,
        UUID tenantUserId,
        Instant createdAt
) {
    public static LeaseResponse from(Lease l) {
        return new LeaseResponse(
                l.getId(),
                l.getAccountId(),
                l.getUnitId(),
                l.getStatus(),
                l.getStartDate(),
                l.getEndDate(),
                l.getTenantUserId(),
                l.getCreatedAt()
        );
    }
}
