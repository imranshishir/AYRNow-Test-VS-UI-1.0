package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.IdempotencyHitException;
import com.ayrnow.domain.entity.IdempotencyKeyRecord;
import com.ayrnow.domain.repository.IdempotencyKeyRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.UUID;

@Service
public class IdempotencyService {

    private static final String PENDING_PLACEHOLDER = "{}";

    private final IdempotencyKeyRepository repository;
    private final ObjectMapper objectMapper;

    public IdempotencyService(IdempotencyKeyRepository repository, ObjectMapper objectMapper) {
        this.repository = repository;
        this.objectMapper = objectMapper;
    }

    /**
     * Execute with idempotency. Call at start of transactional block.
     * If key exists with same request hash, throw IdempotencyHitException with cached response.
     * If key exists with different hash, throw ConflictException.
     * If key does not exist, insert placeholder and return (caller does work, then complete()).
     */
    public void claimOrThrow(UUID accountId, String key, String endpoint, Object request, Class<?> responseType) {
        if (key == null || key.isBlank()) return;
        String k = key.trim();
        String requestHash = hashRequest(request);
        IdempotencyKeyRecord existing = repository.findByAccountIdAndKeyAndEndpoint(accountId, k, endpoint)
                .orElse(null);
        if (existing != null) {
            if (!existing.getRequestHash().equals(requestHash)) {
                throw new ConflictException("Idempotency-Key reuse with different payload");
            }
            if (!PENDING_PLACEHOLDER.equals(existing.getResponseJson())) {
                try {
                    Object cached = objectMapper.readValue(existing.getResponseJson(), responseType);
                    throw new IdempotencyHitException(cached);
                } catch (JsonProcessingException e) {
                    throw new ConflictException("Idempotency conflict");
                }
            }
            throw new ConflictException("Idempotency key in use, please retry");
        }
        IdempotencyKeyRecord r = new IdempotencyKeyRecord();
        r.setAccountId(accountId);
        r.setKey(k);
        r.setEndpoint(endpoint);
        r.setRequestHash(requestHash);
        r.setResponseJson(PENDING_PLACEHOLDER);
        try {
            repository.save(r);
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            existing = repository.findByAccountIdAndKeyAndEndpoint(accountId, k, endpoint).orElse(null);
            if (existing == null) throw e;
            if (!existing.getRequestHash().equals(requestHash)) {
                throw new ConflictException("Idempotency-Key reuse with different payload");
            }
            if (!PENDING_PLACEHOLDER.equals(existing.getResponseJson())) {
                try {
                    Object cached = objectMapper.readValue(existing.getResponseJson(), responseType);
                    throw new IdempotencyHitException(cached);
                } catch (JsonProcessingException ex) {
                    throw new ConflictException("Idempotency conflict");
                }
            }
            throw new ConflictException("Idempotency key in use, please retry");
        }
    }

    public void complete(UUID accountId, String key, String endpoint, Object response) {
        if (key == null || key.isBlank()) return;
        try {
            String responseJson = objectMapper.writeValueAsString(response);
            IdempotencyKeyRecord r = repository.findByAccountIdAndKeyAndEndpoint(accountId, key.trim(), endpoint)
                    .orElseThrow(() -> new IllegalStateException("Idempotency key not claimed"));
            r.setResponseJson(responseJson);
            repository.save(r);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize response for idempotency", e);
        }
    }

    public String hashRequest(Object request) {
        try {
            String json = objectMapper.writeValueAsString(request);
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(json.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (JsonProcessingException | NoSuchAlgorithmException e) {
            throw new RuntimeException("Failed to hash request", e);
        }
    }
}
