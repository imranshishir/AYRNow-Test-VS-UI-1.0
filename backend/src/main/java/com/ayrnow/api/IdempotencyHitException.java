package com.ayrnow.api;

/**
 * Thrown when an idempotent request was already processed. Carries the cached response.
 * Controller should catch and return 200/201 with the response body.
 */
public class IdempotencyHitException extends RuntimeException {

    private final Object cachedResponse;

    public IdempotencyHitException(Object cachedResponse) {
        super("Idempotency key already used");
        this.cachedResponse = cachedResponse;
    }

    public Object getCachedResponse() {
        return cachedResponse;
    }
}
