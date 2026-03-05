package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.MaintenanceTicket;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record TicketResponse(
        UUID id,
        UUID propertyId,
        UUID unitId,
        UUID createdByUserId,
        String title,
        String description,
        String status,
        String priority,
        UUID assignedContractorId,
        AssignmentSummary assignment,
        Instant createdAt,
        Instant updatedAt
) {
    public record AssignmentSummary(UUID id, UUID contractorId, String contractorName, String status) {}

    public static TicketResponse from(MaintenanceTicket t) {
        return from(t, null);
    }

    public static TicketResponse from(MaintenanceTicket t, AssignmentSummary assignment) {
        return new TicketResponse(
                t.getId(),
                t.getPropertyId(),
                t.getUnitId(),
                t.getCreatedByUserId(),
                t.getTitle(),
                t.getDescription(),
                t.getStatus(),
                t.getPriority(),
                t.getAssignedContractorId(),
                assignment,
                t.getCreatedAt(),
                t.getUpdatedAt()
        );
    }
}
