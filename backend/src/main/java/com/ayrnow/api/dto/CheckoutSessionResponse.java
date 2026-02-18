package com.ayrnow.api.dto;

public record CheckoutSessionResponse(
        String checkoutSessionId,
        String checkoutUrl
) {}
