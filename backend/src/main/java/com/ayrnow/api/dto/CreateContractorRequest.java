package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record CreateContractorRequest(
        @NotBlank(message = "name is required")
        @Size(min = 1, max = 255)
        String name,
        @Size(max = 255)
        String email,
        @Size(max = 50)
        String phone,
        @Size(max = 255)
        String company,
        @Size(max = 100)
        String specialty,
        @Pattern(regexp = "^(active|inactive)$", message = "status must be active or inactive")
        String status
) {}
