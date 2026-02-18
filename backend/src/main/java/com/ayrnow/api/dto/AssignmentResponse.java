package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.Contractor;
import com.ayrnow.domain.entity.ContractorAssignment;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record AssignmentResponse(
        UUID id,
        UUID contractorId,
        String contractorName,
        UUID ticketId,
        String status,
        Instant assignedAt,
        Instant acceptedAt,
        Instant completedAt,
        String notes
) {
    public static AssignmentResponse from(ContractorAssignment a, Contractor contractor) {
        return new AssignmentResponse(
                a.getId(),
                a.getContractorId(),
                contractor != null ? contractor.getName() : null,
                a.getTicketId(),
                a.getStatus(),
                a.getAssignedAt(),
                a.getAcceptedAt(),
                a.getCompletedAt(),
                a.getNotes()
        );
    }

    public static AssignmentResponse from(ContractorAssignment a) {
        return from(a, null);
    }
}
