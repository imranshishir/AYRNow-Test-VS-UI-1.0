package com.ayrnow.api.dto;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record PatchAssignmentRequest(
        @Pattern(regexp = "^(assigned|accepted|in_progress|completed|canceled)$",
                message = "status must be assigned, accepted, in_progress, completed, or canceled")
        String status,
        @Size(max = 2000)
        String notes
) {}
