package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.UUID;

public record CreateChargeRequest(
        @NotNull(message = "unitId is required")
        UUID unitId,
        UUID leaseId,
        @NotBlank(message = "subtype is required")
        @Size(max = 50)
        String subtype,
        @NotNull(message = "amountCents is required")
        @Positive(message = "amountCents must be positive")
        long amountCents,
        @NotNull(message = "occurredOn is required")
        LocalDate occurredOn,
        @Size(max = 500)
        String memo
) {}
