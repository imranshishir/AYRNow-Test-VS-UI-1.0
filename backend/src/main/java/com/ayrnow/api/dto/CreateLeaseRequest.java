package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;
import java.util.UUID;

public record CreateLeaseRequest(
        @NotNull(message = "unitId is required")
        UUID unitId,
        @NotNull(message = "tenantUserId is required")
        UUID tenantUserId,
        @NotNull(message = "startDate is required")
        LocalDate startDate,
        LocalDate endDate
) {}
