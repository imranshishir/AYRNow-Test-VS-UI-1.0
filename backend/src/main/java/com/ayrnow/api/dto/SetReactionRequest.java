package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotBlank;

public record SetReactionRequest(
        @NotBlank(message = "reaction is required")
        String reaction
) {}
