package com.ayrnow.config;

import com.stripe.Stripe;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class StripeConfig {

    private static final Logger log = LoggerFactory.getLogger(StripeConfig.class);

    private final String stripeSecretKey;

    public StripeConfig(@Value("${stripe.secretKey:}") String stripeSecretKey) {
        this.stripeSecretKey = stripeSecretKey;
    }

    @PostConstruct
    public void init() {
        if (stripeSecretKey == null || stripeSecretKey.isBlank()) {
            log.info("Stripe not configured - using stub payments");
            return;
        }

        Stripe.apiKey = stripeSecretKey;

        if (stripeSecretKey.startsWith("sk_test_")) {
            log.info("Stripe running in TEST mode");
        } else {
            log.info("Stripe secret key configured");
        }
    }
}

