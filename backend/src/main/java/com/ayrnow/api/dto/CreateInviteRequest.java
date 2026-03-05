package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record CreateInviteRequest(
        @NotBlank(message = "contactType is required")
        @Pattern(regexp = "^(email|phone)$", message = "contactType must be email or phone")
        String contactType,
        @NotBlank(message = "contactValue is required")
        String contactValue,
        @Pattern(regexp = "^(tenant|family|cotenant)$", message = "role must be tenant, family, or cotenant")
        String role
) {}
