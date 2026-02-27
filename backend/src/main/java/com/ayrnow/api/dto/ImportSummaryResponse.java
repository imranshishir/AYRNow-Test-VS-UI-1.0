package com.ayrnow.api.dto;

import java.util.List;
import java.util.UUID;

public record ImportSummaryResponse(
        UUID tenantUserId,
        String displayName,
        Double ratingAvg,
        long ratingCount,
        List<ReviewSummary> reviews
) {
    public record ReviewSummary(UUID id, UUID fromAccountId, int rating, String reviewText, java.time.Instant createdAt) {}
}
