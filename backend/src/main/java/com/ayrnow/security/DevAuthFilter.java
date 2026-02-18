package com.ayrnow.security;

import com.ayrnow.config.AuthProperties;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.UUID;

@Component
@ConditionalOnProperty(name = "auth.dev-headers-enabled", havingValue = "true")
public class DevAuthFilter extends OncePerRequestFilter {

    private static final String HEADER_ACCOUNT_ID = "X-Dev-AccountId";
    private static final String HEADER_USER_ID = "X-Dev-UserId";
    private static final String HEADER_ROLE = "X-Dev-Role";

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        if (!request.getRequestURI().contains("/api/v1/")) return true;
        if (request.getRequestURI().contains("/api/v1/health")) return true;
        if (request.getRequestURI().startsWith("/actuator/")) return true;
        if (request.getRequestURI().contains("/payments/stripe/webhook")) return true;
        if (request.getRequestURI().contains("/auth/")) return true;
        if (SecurityContextHolder.getContext().getAuthentication() != null
                && SecurityContextHolder.getContext().getAuthentication().isAuthenticated()) {
            return true;
        }
        return false;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String accountIdStr = request.getHeader(HEADER_ACCOUNT_ID);
        String userIdStr = request.getHeader(HEADER_USER_ID);
        String role = request.getHeader(HEADER_ROLE);

        if (accountIdStr == null || accountIdStr.isBlank() ||
                userIdStr == null || userIdStr.isBlank() ||
                role == null || role.isBlank()) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Missing X-Dev-AccountId, X-Dev-UserId, or X-Dev-Role header\"}");
            return;
        }

        try {
            UUID accountId = UUID.fromString(accountIdStr.trim());
            UUID userId = UUID.fromString(userIdStr.trim());
            DevAuthPrincipal principal = new DevAuthPrincipal(accountId, userId, role.trim());
            UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                    principal,
                    null,
                    Collections.emptyList()
            );
            SecurityContextHolder.getContext().setAuthentication(auth);
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Invalid UUID in X-Dev-AccountId or X-Dev-UserId\"}");
            return;
        }

        filterChain.doFilter(request, response);
    }
}
