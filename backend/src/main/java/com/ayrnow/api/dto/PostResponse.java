package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.CommunityPost;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record PostResponse(
        UUID id,
        UUID accountId,
        UUID propertyId,
        UUID unitId,
        UUID authorUserId,
        String title,
        String body,
        String kind,
        Instant createdAt,
        Instant updatedAt,
        long commentCount,
        long reactionCount
) {
    public static PostResponse from(CommunityPost p, long commentCount, long reactionCount) {
        return new PostResponse(
                p.getId(),
                p.getAccountId(),
                p.getPropertyId(),
                p.getUnitId(),
                p.getAuthorUserId(),
                p.getTitle(),
                p.getBody(),
                p.getKind(),
                p.getCreatedAt(),
                p.getUpdatedAt(),
                commentCount,
                reactionCount
        );
    }
}
