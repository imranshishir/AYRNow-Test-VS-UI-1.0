package com.ayrnow.api.dto;

import java.util.List;
import java.util.UUID;

public record TenantProfileMeResponse(
        UUID userId,
        String displayName,
        String about,
        String phone,
        String email,
        String lastKnownAddress,
        Double ratingAvg,
        long ratingCount,
        List<ReviewSummary> recentReviews
) {
    public record ReviewSummary(UUID id, UUID fromAccountId, int rating, String reviewText, java.time.Instant createdAt) {}
}
