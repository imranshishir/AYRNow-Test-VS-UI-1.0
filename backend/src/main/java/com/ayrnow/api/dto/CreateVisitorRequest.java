package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public record CreateVisitorRequest(
        @NotNull(message = "propertyId is required")
        UUID propertyId,
        UUID unitId,
        @NotBlank(message = "visitorName is required")
        @Size(min = 1, max = 200)
        String visitorName,
        @Size(max = 50)
        String visitorPhone,
        @Size(max = 500)
        String purpose
) {}
