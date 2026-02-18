package com.ayrnow.api.dto;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public record PatchTicketRequest(
        @Size(min = 1, max = 255)
        String title,
        @Size(max = 2000)
        String description,
        @Pattern(regexp = "^(low|medium|high|urgent)$", message = "priority must be low, medium, high, or urgent")
        String priority,
        @Pattern(regexp = "^(open|in_progress|closed)$", message = "status must be open, in_progress, or closed")
        String status,
        UUID assignedContractorId
) {}
