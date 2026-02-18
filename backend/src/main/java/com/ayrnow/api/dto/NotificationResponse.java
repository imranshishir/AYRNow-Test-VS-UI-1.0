package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.Notification;

import java.time.Instant;
import java.util.UUID;

public record NotificationResponse(
        UUID id,
        String type,
        UUID refId,
        String title,
        String body,
        Instant readAt,
        Instant createdAt
) {
    public static NotificationResponse from(Notification n) {
        return new NotificationResponse(
                n.getId(),
                n.getType(),
                n.getRefId(),
                n.getTitle(),
                n.getBody(),
                n.getReadAt(),
                n.getCreatedAt()
        );
    }
}
