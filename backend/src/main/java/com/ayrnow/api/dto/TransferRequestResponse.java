package com.ayrnow.api.dto;

import java.time.Instant;
import java.util.UUID;

public record TransferRequestResponse(
        UUID id,
        UUID exportId,
        UUID requestingAccountId,
        UUID requestingUserId,
        String status,
        Instant requestedAt,
        Instant decidedAt,
        UUID decisionByUserId
) {}
