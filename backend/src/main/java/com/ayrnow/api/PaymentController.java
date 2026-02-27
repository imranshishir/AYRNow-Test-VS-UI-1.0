package com.ayrnow.api;

import com.ayrnow.api.dto.CheckoutSessionResponse;
import com.ayrnow.api.dto.CreateCheckoutSessionRequest;
import com.ayrnow.api.dto.PageResponse;
import com.ayrnow.api.dto.PaymentRecordResponse;
import com.ayrnow.domain.entity.PaymentRecord;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.PaymentService;
import com.ayrnow.service.StripeService;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/payments")
public class PaymentController {

    private final StripeService stripeService;
    private final PaymentService paymentService;

    public PaymentController(StripeService stripeService, PaymentService paymentService) {
        this.stripeService = stripeService;
        this.paymentService = paymentService;
    }

    @PostMapping("/stripe/checkout-session")
    public ResponseEntity<CheckoutSessionResponse> createCheckoutSession(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @Valid @RequestBody CreateCheckoutSessionRequest req) {
        paymentService.requirePaymentAccess(
                principal.accountId(), req.unitId(), req.leaseId(),
                principal.userId(), principal.role());

        SessionCreateParams params = stripeService.createCheckoutParams(
                principal.accountId(), req.unitId(), req.leaseId(),
                req.amountCents(), principal.userId());
        Session session = stripeService.createCheckoutSession(params);

        String paymentIntentId = StripeSessionHelper.getPaymentIntentId(session);

        paymentService.create(
                principal.accountId(),
                req.unitId(),
                req.leaseId(),
                req.amountCents(),
                principal.userId(),
                session.getId(),
                paymentIntentId
        );

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new CheckoutSessionResponse(session.getId(), session.getUrl()));
    }

    @GetMapping("/history")
    public PageResponse<PaymentRecordResponse> listHistory(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @RequestParam(required = false) UUID unitId,
            @RequestParam(required = false) UUID leaseId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<PaymentRecord> records = paymentService.listHistory(
                principal.accountId(),
                unitId,
                leaseId,
                page,
                size,
                principal.userId(),
                principal.role()
        );
        return PageResponse.from(records.map(PaymentRecordResponse::from));
    }
}
