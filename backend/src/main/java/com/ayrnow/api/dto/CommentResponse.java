package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.PostComment;

import java.time.Instant;
import java.util.UUID;

public record CommentResponse(
        UUID id,
        UUID postId,
        UUID userId,
        String body,
        Instant createdAt
) {
    public static CommentResponse from(PostComment c) {
        return new CommentResponse(
                c.getId(),
                c.getPostId(),
                c.getUserId(),
                c.getBody(),
                c.getCreatedAt()
        );
    }
}
