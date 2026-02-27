package com.ayrnow.api.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record MeResponse(
        UUID accountId,
        UUID userId,
        String role,
        UserInfo user
) {
    public record UserInfo(String email, String displayName) {}

    public static MeResponse fromPrincipal(UUID accountId, UUID userId, String role) {
        return new MeResponse(accountId, userId, role, null);
    }

    public static MeResponse withUser(UUID accountId, UUID userId, String role, String email, String displayName) {
        return new MeResponse(accountId, userId, role, new UserInfo(email, displayName));
    }
}
