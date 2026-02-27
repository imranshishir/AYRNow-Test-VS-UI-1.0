package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public record CreateAssignmentRequest(
        @NotNull(message = "ticketId is required")
        UUID ticketId,
        @NotNull(message = "contractorId is required")
        UUID contractorId,
        @Size(max = 2000)
        String notes
) {}
