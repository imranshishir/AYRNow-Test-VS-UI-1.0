package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.LedgerEntry;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record LedgerEntryResponse(
        UUID id,
        UUID unitId,
        UUID leaseId,
        String type,
        String subtype,
        long amountCents,
        String currency,
        String direction,
        LocalDate occurredOn,
        String memo,
        UUID createdByUserId,
        Instant createdAt
) {
    public static LedgerEntryResponse from(LedgerEntry e) {
        return new LedgerEntryResponse(
                e.getId(),
                e.getUnitId(),
                e.getLeaseId(),
                e.getType(),
                e.getSubtype(),
                e.getAmountCents(),
                e.getCurrency(),
                e.getDirection(),
                e.getOccurredOn(),
                e.getMemo(),
                e.getCreatedByUserId(),
                e.getCreatedAt()
        );
    }
}
