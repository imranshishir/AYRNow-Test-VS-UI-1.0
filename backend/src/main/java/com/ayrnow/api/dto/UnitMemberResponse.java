package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.UnitMember;

import java.time.Instant;
import java.util.UUID;

public record UnitMemberResponse(
        UUID userId,
        String role,
        Instant addedAt
) {
    public static UnitMemberResponse from(UnitMember m) {
        return new UnitMemberResponse(m.getUserId(), m.getRole(), m.getAddedAt());
    }
}
