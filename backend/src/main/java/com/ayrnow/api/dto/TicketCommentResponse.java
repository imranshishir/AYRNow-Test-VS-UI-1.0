package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.TicketComment;

import java.time.Instant;
import java.util.UUID;

public record TicketCommentResponse(
        UUID id,
        UUID ticketId,
        UUID userId,
        String body,
        Instant createdAt
) {
    public static TicketCommentResponse from(TicketComment c) {
        return new TicketCommentResponse(
                c.getId(),
                c.getTicketId(),
                c.getUserId(),
                c.getBody(),
                c.getCreatedAt()
        );
    }
}
