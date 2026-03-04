package com.ayrnow.controller;

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
}
