package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.util.UUID;

public record CreateCheckoutSessionRequest(
        @NotNull(message = "unitId is required")
        UUID unitId,
        UUID leaseId,
        @NotNull(message = "amountCents is required")
        @Positive(message = "amountCents must be positive")
        long amountCents
) {}
