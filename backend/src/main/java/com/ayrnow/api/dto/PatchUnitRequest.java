package com.ayrnow.api.dto;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Partial update for a unit. All fields optional; only non-null values are applied.
 */
public record PatchUnitRequest(
        @Size(min = 1, max = 50, message = "unitLabel must be 1-50 chars when provided")
        String unitLabel,
        @Pattern(regexp = "^(vacant|occupied|maintenance|reserved)$", message = "status must be one of: vacant, occupied, maintenance, reserved")
        String status
) {}
