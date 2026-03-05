package com.ayrnow.api.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record AssignTicketRequest(
        @NotNull(message = "contractorId is required")
        UUID contractorId
) {}
