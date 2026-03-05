package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.VisitorEntry;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record VisitorEntryResponse(
        UUID id,
        UUID propertyId,
        UUID unitId,
        UUID createdByUserId,
        String visitorName,
        String visitorPhone,
        String purpose,
        String status,
        UUID approvedByUserId,
        Instant approvedAt,
        UUID deniedByUserId,
        Instant deniedAt,
        Instant createdAt
) {
    public static VisitorEntryResponse from(VisitorEntry v) {
        return new VisitorEntryResponse(
                v.getId(),
                v.getPropertyId(),
                v.getUnitId(),
                v.getCreatedByUserId(),
                v.getVisitorName(),
                v.getVisitorPhone(),
                v.getPurpose(),
                v.getStatus(),
                v.getApprovedByUserId(),
                v.getApprovedAt(),
                v.getDeniedByUserId(),
                v.getDeniedAt(),
                v.getCreatedAt()
        );
    }
}
