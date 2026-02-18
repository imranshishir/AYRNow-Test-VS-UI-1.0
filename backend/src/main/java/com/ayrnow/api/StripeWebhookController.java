package com.ayrnow.api;

import com.ayrnow.service.StripeWebhookService;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.net.Webhook;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * Stripe webhook endpoint. Must be publicly accessible (no dev auth).
 * Signature verification is required.
 */
@RestController
@RequestMapping("/api/v1/payments/stripe")
public class StripeWebhookController {

    private static final Logger log = LoggerFactory.getLogger(StripeWebhookController.class);

    private final StripeWebhookService webhookService;

    public StripeWebhookController(StripeWebhookService webhookService) {
        this.webhookService = webhookService;
    }

    @PostMapping("/webhook")
    public ResponseEntity<String> handleWebhook(HttpServletRequest request) {
        String payload;
        try {
            payload = new String(request.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        } catch (IOException e) {
            log.error("Failed to read webhook body: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to read body");
        }
        String signature = request.getHeader("Stripe-Signature");
        if (signature == null || signature.isBlank()) {
            log.warn("Webhook received without Stripe-Signature header");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Missing Stripe-Signature");
        }
        try {
            Event event = webhookService.constructEvent(payload, signature);
            webhookService.processEvent(event);
            return ResponseEntity.ok("OK");
        } catch (SignatureVerificationException e) {
            log.warn("Invalid webhook signature: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid signature");
        } catch (Exception e) {
            log.error("Webhook processing failed: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Processing failed");
        }
    }
}
