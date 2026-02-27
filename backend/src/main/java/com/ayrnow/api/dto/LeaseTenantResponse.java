package com.ayrnow.api.dto;

import java.util.UUID;

public record LeaseTenantResponse(
        UUID userId,
        String role,
        String displayName,
        String email
) {}
