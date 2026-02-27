package com.ayrnow.security;

import java.util.UUID;

/**
 * Principal for dev auth (X-Dev-* headers).
 */
public record DevAuthPrincipal(UUID accountId, UUID userId, String role) {
}
