package com.ayrnow.api.dto;

import java.util.UUID;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        UUID userId,
        UUID accountId,
        String role
) {}
