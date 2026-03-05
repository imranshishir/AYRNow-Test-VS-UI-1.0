package com.ayrnow.api.dto;

import java.util.List;
import java.util.UUID;

public record MarkReadRequest(
        List<UUID> notificationIds,
        Boolean all
) {}
