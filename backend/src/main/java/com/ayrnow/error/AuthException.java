package com.ayrnow.error;

/**
 * Auth failure (invalid credentials, unverified email, invalid/expired token).
 * Handler returns 401 with message; never log raw tokens.
 */
public class AuthException extends RuntimeException {

    public AuthException(String message) {
        super(message);
    }

    public AuthException(String message, Throwable cause) {
        super(message, cause);
    }
}
