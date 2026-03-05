package com.ayrnow.service;

import com.ayrnow.domain.LedgerEntry;
import com.ayrnow.domain.Payment;
import com.ayrnow.domain.Unit;
import com.ayrnow.dto.CreatePaymentIntentRequest;
import com.ayrnow.dto.PaymentIntentResponse;
import com.ayrnow.repository.LedgerEntryRepository;
import com.ayrnow.repository.PaymentRepository;
import com.ayrnow.repository.PropertyRepository;
import com.ayrnow.repository.UnitRepository;
import com.stripe.exception.StripeException;
import com.stripe.model.PaymentIntent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Service
public class PaymentService {

    private static final Logger log = LoggerFactory.getLogger(PaymentService.class);

    private final PaymentRepository paymentRepository;
    private final LedgerEntryRepository ledgerRepository;
    private final UnitRepository unitRepository;
    private final PropertyRepository propertyRepository;
    private final NotificationService notificationService;
    private final AccessControlService accessControlService;
    private final String stripeSecretKey;

    public PaymentService(PaymentRepository paymentRepository, LedgerEntryRepository ledgerRepository,
                          UnitRepository unitRepository, PropertyRepository propertyRepository,
                          NotificationService notificationService, AccessControlService accessControlService,
                          @Value("${stripe.secretKey:}") String stripeSecretKey) {
        this.paymentRepository = paymentRepository;
        this.ledgerRepository = ledgerRepository;
        this.unitRepository = unitRepository;
        this.propertyRepository = propertyRepository;
        this.notificationService = notificationService;
        this.accessControlService = accessControlService;
        this.stripeSecretKey = stripeSecretKey;
    }

    @Transactional
    public PaymentIntentResponse createIntent(CreatePaymentIntentRequest req, UUID tenantUserId) {
        if (!accessControlService.isTenantOfUnit(tenantUserId, req.getUnitId())) {
            throw new org.springframework.security.access.AccessDeniedException("Must be tenant of unit");
        }
        if (stripeSecretKey == null || stripeSecretKey.isBlank()) {
            Payment p = new Payment();
            p.setId(UUID.randomUUID());
            p.setUnitId(req.getUnitId());
            p.setTenantUserId(tenantUserId);
            int amountCents = resolveAmountCents(req);
            p.setAmountCents(amountCents);
            p.setCurrency(resolveCurrency(req));
            p.setStatus("stubbed");
            p.setCreatedAt(Instant.now());
            p = paymentRepository.save(p);

            LedgerEntry le = new LedgerEntry();
            le.setId(UUID.randomUUID());
            le.setUnitId(req.getUnitId());
            le.setEntryType("payment");
            le.setAmountCents(p.getAmountCents());
            le.setMemo("Payment received");
            le.setCreatedAt(Instant.now());
            ledgerRepository.save(le);

            Unit u = unitRepository.findById(req.getUnitId()).orElse(null);
            if (u != null) {
                var prop = propertyRepository.findById(u.getPropertyId()).orElse(null);
                if (prop != null && prop.getOwnerUserId() != null) {
                    Map<String, String> params = new HashMap<>();
                    params.put("propertyId", u.getPropertyId().toString());
                    params.put("unitId", req.getUnitId().toString());
                    params.put("targetRole", "landlord");
                    notificationService.notifyUser(prop.getOwnerUserId(), "announcement", "Payment received",
                            "Rent payment of $" + (p.getAmountCents() / 100.0) + " received.", "/L-30", params);
                }
            }
            return new PaymentIntentResponse(p.getId().toString(), "stubbed", null);
        }
        Payment p = new Payment();
        p.setId(UUID.randomUUID());
        p.setUnitId(req.getUnitId());
        p.setTenantUserId(tenantUserId);
        int amountCents = resolveAmountCents(req);
        p.setAmountCents(amountCents);
        String currency = resolveCurrency(req);
        p.setCurrency(currency);
        p.setStatus("pending");
        p.setCreatedAt(Instant.now());
        paymentRepository.save(p);

        Map<String, Object> params = new HashMap<>();
        params.put("amount", amountCents);
        params.put("currency", currency);

        try {
            PaymentIntent intent = PaymentIntent.create(params);
            p.setStripePaymentIntentId(intent.getId());
            paymentRepository.save(p);
            log.info("Created Stripe PaymentIntent {} for payment {}", intent.getId(), p.getId());
            return new PaymentIntentResponse(p.getId().toString(), "pending", intent.getClientSecret());
        } catch (StripeException e) {
            log.error("Failed to create Stripe PaymentIntent for payment {}", p.getId(), e);
            throw new IllegalStateException("Unable to create Stripe PaymentIntent", e);
        }
    }

    @Transactional(readOnly = true)
    public java.util.List<Payment> listForTenant(UUID tenantUserId) {
        return paymentRepository.findByTenantUserIdOrderByCreatedAtDesc(tenantUserId);
    }

    private int resolveAmountCents(CreatePaymentIntentRequest req) {
        Integer cents = req.getAmountCents();
        if (cents != null) {
            if (cents <= 0) {
                throw new IllegalArgumentException("amountCents must be positive");
            }
            return cents;
        }
        Integer amount = req.getAmount();
        if (amount != null) {
            if (amount <= 0) {
                throw new IllegalArgumentException("amount must be positive");
            }
            return amount * 100;
        }
        // Fallback to existing default for backwards compatibility
        int defaultCents = 120000;
        if (defaultCents <= 0) {
            throw new IllegalArgumentException("Default amount must be positive");
        }
        return defaultCents;
    }

    private String resolveCurrency(CreatePaymentIntentRequest req) {
        String currency = req.getCurrency();
        if (currency == null || currency.isBlank()) {
            return "usd";
        }
        return currency.toLowerCase(Locale.ROOT);
    }
}
