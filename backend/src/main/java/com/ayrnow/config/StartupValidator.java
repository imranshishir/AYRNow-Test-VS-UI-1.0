package com.ayrnow.config;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * Phase B13: Fail-fast validation for staging/prod profiles.
 * Does not log secret values.
 */
@Component
@Profile({"staging", "prod"})
public class StartupValidator implements ApplicationRunner {

    private final Environment env;

    public StartupValidator(Environment env) {
        this.env = env;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!env.acceptsProfiles(Profiles.of("staging", "prod"))) {
            return;
        }

        List<String> errors = new ArrayList<>();

        if (Boolean.TRUE.equals(env.getProperty("auth.dev-headers-enabled", Boolean.class, false))) {
            errors.add("auth.dev-headers-enabled must be false for staging/prod profiles");
        }

        String jwtSecret = env.getProperty("auth.jwt.secret");
        if (jwtSecret == null || jwtSecret.isBlank() || jwtSecret.contains("dev-secret") || jwtSecret.length() < 32) {
            errors.add("JWT_SECRET must be set and at least 32 characters for staging/prod");
        }

        String stripeWebhookSecret = env.getProperty("stripe.webhook-secret");
        if (stripeWebhookSecret == null || stripeWebhookSecret.isBlank()) {
            errors.add("STRIPE_WEBHOOK_SECRET must be set for staging/prod");
        }

        String stripeSecretKey = env.getProperty("stripe.secret-key");
        if (stripeSecretKey == null || stripeSecretKey.isBlank()) {
            errors.add("STRIPE_SECRET_KEY must be set for staging/prod");
        }

        String corsOrigins = env.getProperty("ayrnow.cors.allowed-origins");
        if (corsOrigins == null || corsOrigins.isBlank() || "*".equals(corsOrigins.trim())) {
            errors.add("CORS_ALLOWED_ORIGINS must be set and must not be * for staging/prod");
        }

        if (!errors.isEmpty()) {
            throw new IllegalStateException(
                    "Startup validation failed: " + String.join("; ", errors));
        }
    }
}
