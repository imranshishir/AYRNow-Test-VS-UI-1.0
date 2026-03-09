package com.ayrnow.service;

import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * In-memory rate limit for verification and forgot-password endpoints.
 * Limits per key (e.g. IP or email) to avoid abuse; does not reveal user existence.
 */
@Service
public class AuthRateLimitService {

    private static final int MAX_ATTEMPTS = 5;
    private static final long WINDOW_SECONDS = 900; // 15 minutes

    private final Map<String, Window> windows = new ConcurrentHashMap<>();

    public boolean isAllowed(String key) {
        Instant now = Instant.now();
        Window w = windows.compute(key, (k, v) -> {
            if (v == null) return new Window(now, 1);
            if (now.isAfter(v.resetAt)) return new Window(now, 1);
            if (v.count >= MAX_ATTEMPTS) return v;
            return new Window(v.start, v.count + 1);
        });
        if (w.count > MAX_ATTEMPTS) return false;
        w.resetAt = w.start.plusSeconds(WINDOW_SECONDS);
        return true;
    }

    public void clear(String key) {
        windows.remove(key);
    }

    private static class Window {
        final Instant start;
        int count;
        Instant resetAt;

        Window(Instant start, int count) {
            this.start = start;
            this.count = count;
            this.resetAt = start.plusSeconds(WINDOW_SECONDS);
        }
    }
}
