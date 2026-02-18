package com.ayrnow.api.dto;

import com.ayrnow.domain.entity.PaymentRecord;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record PaymentRecordResponse(
        UUID id,
        UUID unitId,
        UUID leaseId,
        String stripeCheckoutSessionId,
        String stripePaymentIntentId,
        long amountCents,
        String currency,
        String status,
        UUID createdByUserId,
        Instant createdAt,
        Instant updatedAt
) {
    public static PaymentRecordResponse from(PaymentRecord p) {
        return new PaymentRecordResponse(
                p.getId(),
                p.getUnitId(),
                p.getLeaseId(),
                p.getStripeCheckoutSessionId(),
                p.getStripePaymentIntentId(),
                p.getAmountCents(),
                p.getCurrency(),
                p.getStatus(),
                p.getCreatedByUserId(),
                p.getCreatedAt(),
                p.getUpdatedAt()
        );
    }
}
