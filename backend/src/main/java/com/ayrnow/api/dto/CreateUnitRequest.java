package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateUnitRequest(
        @NotBlank(message = "unitLabel is required")
        String unitLabel,
        String status
) {}
