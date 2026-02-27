package com.ayrnow.api;

/**
 * Thrown when an operation cannot proceed due to a business rule conflict (e.g. unit has active lease).
 * Maps to HTTP 409 Conflict.
 */
public class ConflictException extends RuntimeException {

    public ConflictException(String message) {
        super(message);
    }
}
