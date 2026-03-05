package com.ayrnow.api.dto;

import java.time.Instant;
import java.util.UUID;

public record ExportResponse(
        UUID exportId,
        String shareToken,
        Instant expiresAt,
        String shareUrl
) {}
