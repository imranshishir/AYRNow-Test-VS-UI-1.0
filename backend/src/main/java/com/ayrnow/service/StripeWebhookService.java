package com.ayrnow.service;

import com.ayrnow.config.StripeConfig;
import com.ayrnow.domain.entity.PaymentRecord;
import com.ayrnow.domain.entity.WebhookEvent;
import com.ayrnow.domain.repository.WebhookEventRepository;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.EventDataObjectDeserializer;
import com.stripe.model.StripeObject;
import com.stripe.net.Webhook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Optional;
import java.util.UUID;

@Service
public class StripeWebhookService {

    private static final Logger log = LoggerFactory.getLogger(StripeWebhookService.class);

    private final StripeConfig stripeConfig;
    private final WebhookEventRepository webhookEventRepository;
    private final PaymentService paymentService;
    private final LedgerService ledgerService;

    public StripeWebhookService(StripeConfig stripeConfig,
                                WebhookEventRepository webhookEventRepository,
                                PaymentService paymentService,
                                LedgerService ledgerService) {
        this.stripeConfig = stripeConfig;
        this.webhookEventRepository = webhookEventRepository;
        this.paymentService = paymentService;
        this.ledgerService = ledgerService;
    }

    public Event constructEvent(String payload, String signature) throws SignatureVerificationException {
        return Webhook.constructEvent(payload, signature, stripeConfig.getWebhookSecret());
    }

    @Transactional
    public void processEvent(Event event) {
        Optional<WebhookEvent> existing = webhookEventRepository.findByStripeEventId(event.getId());
        if (existing.isPresent()) {
            log.info("Webhook event already processed (dedup): {}", event.getId());
            return;
        }
        WebhookEvent we = new WebhookEvent();
        we.setStripeEventId(event.getId());
        we.setType(event.getType());
        we.setStatus("received");
        try {
            webhookEventRepository.save(we);
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            log.info("Webhook event duplicate (concurrent): {}", event.getId());
            return;
        }

        try {
            handleEvent(event, we);
            we.setStatus("processed");
            we.setProcessedAt(Instant.now());
            we.setAccountId(we.getAccountId());
            webhookEventRepository.save(we);
        } catch (Exception e) {
            log.error("Webhook processing failed for event {}: {}", event.getId(), e.getMessage());
            we.setStatus("failed");
            we.setError(e.getMessage());
            we.setProcessedAt(Instant.now());
            webhookEventRepository.save(we);
            throw new RuntimeException("Webhook processing failed", e);
        }
    }

    private void handleEvent(Event event, WebhookEvent we) {
        switch (event.getType()) {
            case "checkout.session.completed" -> handleCheckoutSessionCompleted(event, we);
            case "payment_intent.succeeded" -> handlePaymentIntentSucceeded(event, we);
            case "payment_intent.payment_failed" -> handlePaymentIntentFailed(event);
            default -> {
                log.info("Ignoring webhook event type: {}", event.getType());
                we.setStatus("ignored");
            }
        }
    }

    private void handleCheckoutSessionCompleted(Event event, WebhookEvent we) {
        EventDataObjectDeserializer data = event.getDataObjectDeserializer();
        StripeObject obj = data.getObject().orElse(null);
        if (!(obj instanceof com.stripe.model.checkout.Session session)) {
            log.warn("checkout.session.completed missing session object");
            return;
        }
        String accountIdStr = session.getMetadata() != null ? session.getMetadata().get("accountId") : null;
        String unitIdStr = session.getMetadata() != null ? session.getMetadata().get("unitId") : null;
        String leaseIdStr = session.getMetadata() != null ? session.getMetadata().get("leaseId") : null;
        String createdByUserIdStr = session.getMetadata() != null ? session.getMetadata().get("createdByUserId") : null;
        if (accountIdStr == null || unitIdStr == null || createdByUserIdStr == null) {
            log.warn("checkout.session.completed missing metadata: accountId, unitId, or createdByUserId");
            return;
        }
        UUID accountId = UUID.fromString(accountIdStr);
        UUID unitId = UUID.fromString(unitIdStr);
        UUID leaseId = leaseIdStr != null ? UUID.fromString(leaseIdStr) : null;
        UUID createdByUserId = UUID.fromString(createdByUserIdStr);
        we.setAccountId(accountId);

        long amountTotal = session.getAmountTotal() != null ? session.getAmountTotal() : 0;
        String paymentIntentId = null;
        try {
            paymentIntentId = session.getPaymentIntent();
        } catch (Exception ignored) {}
        PaymentRecord updated = paymentService.markSucceededBySessionId(session.getId());
        if (updated == null) {
            log.warn("No payment record found for session {}", session.getId());
            return;
        }
        String piId = paymentIntentId != null ? paymentIntentId : updated.getStripePaymentIntentId();
        createLedgerPayment(accountId, createdByUserId, unitId, leaseId, amountTotal,
                session.getId(), piId, event.getId(), we);
    }

    private void handlePaymentIntentSucceeded(Event event, WebhookEvent we) {
        EventDataObjectDeserializer data = event.getDataObjectDeserializer();
        StripeObject obj = data.getObject().orElse(null);
        if (!(obj instanceof com.stripe.model.PaymentIntent pi)) {
            log.warn("payment_intent.succeeded missing PaymentIntent object");
            return;
        }
        String accountIdStr = pi.getMetadata() != null ? pi.getMetadata().get("accountId") : null;
        String unitIdStr = pi.getMetadata() != null ? pi.getMetadata().get("unitId") : null;
        String leaseIdStr = pi.getMetadata() != null ? pi.getMetadata().get("leaseId") : null;
        String createdByUserIdStr = pi.getMetadata() != null ? pi.getMetadata().get("createdByUserId") : null;

        PaymentRecord pr = paymentService.markSucceededByPaymentIntentId(pi.getId());
        if (pr == null) {
            log.warn("No payment record found for payment_intent {}", pi.getId());
            we.setStatus("ignored");
            return;
        }
        we.setAccountId(pr.getAccountId());
        UUID accountId = accountIdStr != null ? UUID.fromString(accountIdStr) : pr.getAccountId();
        UUID unitId = unitIdStr != null ? UUID.fromString(unitIdStr) : pr.getUnitId();
        UUID leaseId = leaseIdStr != null ? UUID.fromString(leaseIdStr) : pr.getLeaseId();
        UUID createdByUserId = createdByUserIdStr != null ? UUID.fromString(createdByUserIdStr) : pr.getCreatedByUserId();
        long amountCents = pi.getAmount() != null ? pi.getAmount() : pr.getAmountCents();

        createLedgerPayment(accountId, createdByUserId, unitId, leaseId, amountCents,
                pr.getStripeCheckoutSessionId(), pi.getId(), event.getId(), we);
    }

    private void handlePaymentIntentFailed(Event event) {
        EventDataObjectDeserializer data = event.getDataObjectDeserializer();
        StripeObject obj = data.getObject().orElse(null);
        if (obj instanceof com.stripe.model.PaymentIntent pi) {
            paymentService.markFailedByPaymentIntentId(pi.getId());
        }
    }

    private void createLedgerPayment(UUID accountId, UUID createdByUserId, UUID unitId, UUID leaseId,
                                     long amountCents, String sessionId, String paymentIntentId,
                                     String stripeEventId, WebhookEvent we) {
        LocalDate occurredOn = LocalDate.now();
        String memo = "Stripe payment. Session: " + (sessionId != null ? sessionId : "") + ", PaymentIntent: " + (paymentIntentId != null ? paymentIntentId : "");
        try {
            ledgerService.createPaymentFromWebhook(
                    accountId, createdByUserId, unitId, leaseId, amountCents, occurredOn, memo,
                    stripeEventId, paymentIntentId);
        } catch (com.ayrnow.api.IdempotencyHitException e) {
            log.info("Ledger payment already created for payment (idempotent replay)");
        }
    }
}
