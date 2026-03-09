package com.ayrnow.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Secure token generation and hashing. Store only hashes in DB; never log raw tokens.
 */
public final class TokenHashUtil {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int TOKEN_BYTES = 32;
    private static final String HASH_ALGORITHM = "SHA-256";

    private TokenHashUtil() {}

    /** Generate a URL-safe random token (e.g. for verification or reset links). */
    public static String generateToken() {
        byte[] bytes = new byte[TOKEN_BYTES];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    /** Hash a token for storage. Returns hex-encoded SHA-256 hash. */
    public static String hashToken(String token) {
        if (token == null || token.isBlank()) return null;
        try {
            MessageDigest digest = MessageDigest.getInstance(HASH_ALGORITHM);
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(hash.length * 2);
            for (byte b : hash) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(HASH_ALGORITHM + " not available", e);
        }
    }

    /** Return true if the raw token matches the stored hash. */
    public static boolean matches(String rawToken, String storedHash) {
        if (rawToken == null || storedHash == null) return false;
        return storedHash.equals(hashToken(rawToken));
    }
}
