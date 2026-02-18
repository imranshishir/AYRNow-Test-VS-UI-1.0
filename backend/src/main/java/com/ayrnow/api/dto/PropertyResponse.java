package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.Property;

import java.time.Instant;
import java.util.UUID;

public record PropertyResponse(
        UUID id,
        UUID accountId,
        String name,
        String address1,
        String city,
        String state,
        String postalCode,
        Instant createdAt
) {
    public static PropertyResponse from(Property p) {
        return new PropertyResponse(
                p.getId(),
                p.getAccountId(),
                p.getName(),
                p.getAddress1(),
                p.getCity(),
                p.getState(),
                p.getPostalCode(),
                p.getCreatedAt()
        );
    }
}
