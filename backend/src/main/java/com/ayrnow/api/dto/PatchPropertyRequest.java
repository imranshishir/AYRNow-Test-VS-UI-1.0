package com.ayrnow.api.dto;

import jakarta.validation.constraints.Size;

/**
 * Partial update for a property. All fields optional; only non-null values are applied.
 */
public record PatchPropertyRequest(
        @Size(min = 1, max = 255, message = "name must be 1-255 chars when provided")
        String name,
        @Size(max = 255)
        String address1,
        @Size(max = 100)
        String city,
        @Size(max = 50)
        String state,
        @Size(max = 20)
        String postalCode
) {}
