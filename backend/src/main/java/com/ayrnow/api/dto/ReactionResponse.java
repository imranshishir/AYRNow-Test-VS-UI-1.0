package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.PostReaction;

import java.time.Instant;
import java.util.UUID;

public record ReactionResponse(
        UUID postId,
        UUID userId,
        String reaction,
        Instant createdAt
) {
    public static ReactionResponse from(PostReaction r) {
        return new ReactionResponse(
                r.getPostId(),
                r.getUserId(),
                r.getReaction(),
                r.getCreatedAt()
        );
    }
}
