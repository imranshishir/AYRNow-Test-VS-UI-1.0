package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.Contractor;

import java.time.Instant;
import java.util.UUID;

public record ContractorResponse(
        UUID id,
        UUID accountId,
        String name,
        String email,
        String phone,
        String company,
        String specialty,
        String status,
        Instant createdAt,
        Instant updatedAt
) {
    public static ContractorResponse from(Contractor c) {
        return new ContractorResponse(
                c.getId(),
                c.getAccountId(),
                c.getName(),
                c.getEmail(),
                c.getPhone(),
                c.getCompany(),
                c.getSpecialty(),
                c.getStatus(),
                c.getCreatedAt(),
                c.getUpdatedAt()
        );
    }
}
