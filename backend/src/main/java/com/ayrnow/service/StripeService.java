package com.ayrnow.service;

import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.config.StripeConfig;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.domain.repository.LeaseRepository;
import com.ayrnow.domain.repository.UnitRepository;
import com.stripe.Stripe;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.util.UUID;

@Service
public class StripeService {

    private static final Logger log = LoggerFactory.getLogger(StripeService.class);

    private final StripeConfig stripeConfig;
    private final UnitRepository unitRepository;
    private final LeaseRepository leaseRepository;

    public StripeService(StripeConfig stripeConfig, UnitRepository unitRepository, LeaseRepository leaseRepository) {
        this.stripeConfig = stripeConfig;
        this.unitRepository = unitRepository;
        this.leaseRepository = leaseRepository;
    }

    @PostConstruct
    public void init() {
        if (stripeConfig.getSecretKey() != null && !stripeConfig.getSecretKey().isBlank()) {
            Stripe.apiKey = stripeConfig.getSecretKey();
        }
    }

    public SessionCreateParams createCheckoutParams(UUID accountId, UUID unitId, UUID leaseId,
                                                    long amountCents, UUID createdByUserId) {
        Unit unit = unitRepository.findByAccountIdAndId(accountId, unitId)
                .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
        if (leaseId != null) {
            leaseRepository.findByAccountIdAndId(accountId, leaseId)
                    .orElseThrow(() -> new ResourceNotFoundException("Lease not found"));
        }
        SessionCreateParams.PaymentIntentData.Builder piData = SessionCreateParams.PaymentIntentData.builder()
                .putMetadata("accountId", accountId.toString())
                .putMetadata("unitId", unitId.toString())
                .putMetadata("createdByUserId", createdByUserId.toString());
        if (leaseId != null) {
            piData.putMetadata("leaseId", leaseId.toString());
        }

        SessionCreateParams.Builder builder = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .setSuccessUrl(stripeConfig.getSuccessUrl())
                .setCancelUrl(stripeConfig.getCancelUrl())
                .setPaymentIntentData(piData.build())
                .putMetadata("accountId", accountId.toString())
                .putMetadata("unitId", unitId.toString())
                .putMetadata("createdByUserId", createdByUserId.toString());
        if (leaseId != null) {
            builder.putMetadata("leaseId", leaseId.toString());
        }
        return builder.addLineItem(
                        SessionCreateParams.LineItem.builder()
                                .setPriceData(
                                        SessionCreateParams.LineItem.PriceData.builder()
                                                .setCurrency("usd")
                                                .setUnitAmount(amountCents)
                                                .setProductData(
                                                        SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                                                .setName("Rent payment")
                                                                .build()
                                                )
                                                .build()
                                )
                                .setQuantity(1L)
                                .build()
                )
                .build();
    }

    public Session createCheckoutSession(SessionCreateParams params) {
        try {
            return Session.create(params);
        } catch (Exception e) {
            log.error("Stripe checkout session creation failed: {}", e.getMessage());
            throw new RuntimeException("Failed to create checkout session", e);
        }
    }
}
