package com.ayrnow.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.Instant;
import java.util.Map;

public record NotificationResponse(
    String id,
    String type,
    String title,
    String body,
    Instant createdAt,
    @JsonProperty("isRead") boolean isRead,
    String route,
    Map<String, String> params,
    String propertyId,
    String unitId,
    String targetRole
) {}
