package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.TenantInvite;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record InviteResponse(
        UUID id,
        UUID unitId,
        String contactType,
        String contactValue,
        String invitedRole,
        String status,
        Instant expiresAt,
        String inviteCode,
        String inviteUrlToken,
        String joinUrl,
        Instant lastSentAt,
        Instant acceptedAt,
        Instant createdAt
) {
    public static InviteResponse from(TenantInvite inv, String baseUrl) {
        String join = baseUrl != null ? baseUrl + "/invite/" + inv.getInviteUrlToken() : "/invite/" + inv.getInviteUrlToken();
        return new InviteResponse(
                inv.getId(),
                inv.getUnitId(),
                inv.getContactType(),
                inv.getContactValue(),
                inv.getInvitedRole(),
                inv.getStatus(),
                inv.getExpiresAt(),
                inv.getInviteCode(),
                inv.getInviteUrlToken(),
                join,
                inv.getLastSentAt(),
                inv.getAcceptedAt(),
                inv.getCreatedAt()
        );
    }

    public static InviteResponse from(TenantInvite inv) {
        return from(inv, null);
    }
}
