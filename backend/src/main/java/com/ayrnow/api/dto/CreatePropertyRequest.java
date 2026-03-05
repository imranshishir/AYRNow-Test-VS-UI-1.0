package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotBlank;

public record CreatePropertyRequest(
        @NotBlank(message = "name is required")
        String name,
        String address1,
        String city,
        String state,
        String postalCode
) {}
