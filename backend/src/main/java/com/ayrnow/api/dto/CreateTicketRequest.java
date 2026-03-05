package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public record CreateTicketRequest(
        @NotNull(message = "propertyId is required")
        UUID propertyId,
        @NotNull(message = "unitId is required")
        UUID unitId,
        @NotNull(message = "title is required")
        @Size(min = 1, max = 255)
        String title,
        @Size(max = 2000)
        String description,
        @Pattern(regexp = "^(low|medium|high|urgent)$", message = "priority must be low, medium, high, or urgent")
        String priority
) {}
