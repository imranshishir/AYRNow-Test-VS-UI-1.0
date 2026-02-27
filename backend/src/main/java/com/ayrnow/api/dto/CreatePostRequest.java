package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public record CreatePostRequest(
        UUID propertyId,
        UUID unitId,
        String title,
        @NotBlank(message = "body is required")
        @Size(min = 1, max = 10000)
        String body,
        String kind
) {}
