package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AddCommentRequest(
        @NotBlank(message = "body is required")
        @Size(min = 1, max = 2000)
        String body
) {}
