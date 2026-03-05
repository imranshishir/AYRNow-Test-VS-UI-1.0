package com.ayrnow.controller;

import com.ayrnow.domain.Payment;
import com.ayrnow.dto.CreatePaymentIntentRequest;
import com.ayrnow.dto.PaymentIntentResponse;
import com.ayrnow.service.PaymentService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/v1/payments")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping("/intent")
    public PaymentIntentResponse createIntent(@Valid @RequestBody CreatePaymentIntentRequest request, Authentication auth) {
        UUID tenantUserId = UUID.fromString(auth.getName());
        return paymentService.createIntent(request, tenantUserId);
    }

    @GetMapping("/mine")
    public java.util.List<PaymentSummaryDto> listMyPayments(Authentication auth) {
        UUID tenantUserId = UUID.fromString(auth.getName());
        java.util.List<Payment> payments = paymentService.listForTenant(tenantUserId);
        java.util.List<PaymentSummaryDto> result = new java.util.ArrayList<>(payments.size());
        for (Payment p : payments) {
            result.add(PaymentSummaryDto.from(p));
        }
        return result;
    }

    public record PaymentSummaryDto(
            String id,
            String unitId,
            int amountCents,
            String currency,
            String status,
            java.time.Instant createdAt
    ) {
        public static PaymentSummaryDto from(Payment p) {
            return new PaymentSummaryDto(
                    p.getId().toString(),
                    p.getUnitId().toString(),
                    p.getAmountCents(),
                    p.getCurrency(),
                    p.getStatus(),
                    p.getCreatedAt()
            );
        }
    }
}
