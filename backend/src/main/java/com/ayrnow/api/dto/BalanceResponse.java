package com.ayrnow.api.dto;

import java.time.LocalDate;
import java.util.UUID;

public record BalanceResponse(
        UUID unitId,
        UUID leaseId,
        long balanceCents,
        String currency,
        LocalDate asOfDate
) {
    public static BalanceResponse forUnit(UUID unitId, long balanceCents, String currency, LocalDate asOfDate) {
        return new BalanceResponse(unitId, null, balanceCents, currency, asOfDate);
    }

    public static BalanceResponse forLease(UUID unitId, UUID leaseId, long balanceCents, String currency, LocalDate asOfDate) {
        return new BalanceResponse(unitId, leaseId, balanceCents, currency, asOfDate);
    }
}
