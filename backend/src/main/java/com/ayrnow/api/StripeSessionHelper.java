package com.ayrnow.api;

import com.stripe.model.checkout.Session;

/**
 * Helper to extract payment_intent id from Stripe Session (varies by SDK version).
 */
final class StripeSessionHelper {

    private StripeSessionHelper() {}

    static String getPaymentIntentId(Session session) {
        try {
            return session.getPaymentIntent();
        } catch (Exception ignored) {}
        return null;
    }
}
