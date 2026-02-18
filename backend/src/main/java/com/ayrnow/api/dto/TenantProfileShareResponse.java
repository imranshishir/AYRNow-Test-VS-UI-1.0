package com.ayrnow.api.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record TenantProfileShareResponse(
        UUID tenantUserId,
        String displayName,
        String about,
        String phone,
        String email,
        String lastKnownAddress,
        Double ratingAvg,
        Long ratingCount,
        List<ReviewSummary> reviews,
        Boolean fullAccess
) {
    public record ReviewSummary(UUID id, UUID fromAccountId, int rating, String reviewText, java.time.Instant createdAt) {}

    public static TenantProfileShareResponse redacted(UUID tenantUserId, String displayName, Double ratingAvg, Long ratingCount) {
        return new TenantProfileShareResponse(tenantUserId, displayName, null, null, null, null, ratingAvg, ratingCount, null, false);
    }

    public static TenantProfileShareResponse full(UUID tenantUserId, String displayName, String about, String phone, String email, String lastKnownAddress,
                                                  Double ratingAvg, Long ratingCount, List<ReviewSummary> reviews) {
        return new TenantProfileShareResponse(tenantUserId, displayName, about, phone, email, lastKnownAddress, ratingAvg, ratingCount, reviews, true);
    }
}
