package com.ayrnow.domain.entity;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "idempotency_keys")
@IdClass(IdempotencyKeyRecord.IdempotencyKeyId.class)
public class IdempotencyKeyRecord {

    @Id
    @Column(name = "account_id", nullable = false, updatable = false)
    private UUID accountId;

    @Id
    @Column(name = "key", nullable = false, updatable = false)
    private String key;

    @Id
    @Column(name = "endpoint", nullable = false, updatable = false)
    private String endpoint;

    @Column(name = "request_hash", nullable = false, updatable = false)
    private String requestHash;

    @Column(name = "response_json", nullable = false, columnDefinition = "jsonb")
    private String responseJson;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = Instant.now();
    }

    public UUID getAccountId() { return accountId; }
    public void setAccountId(UUID accountId) { this.accountId = accountId; }
    public String getKey() { return key; }
    public void setKey(String key) { this.key = key; }
    public String getEndpoint() { return endpoint; }
    public void setEndpoint(String endpoint) { this.endpoint = endpoint; }
    public String getRequestHash() { return requestHash; }
    public void setRequestHash(String requestHash) { this.requestHash = requestHash; }
    public String getResponseJson() { return responseJson; }
    public void setResponseJson(String responseJson) { this.responseJson = responseJson; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public static final class IdempotencyKeyId implements java.io.Serializable {
        private UUID accountId;
        private String key;
        private String endpoint;

        public IdempotencyKeyId() {}
        public IdempotencyKeyId(UUID accountId, String key, String endpoint) {
            this.accountId = accountId;
            this.key = key;
            this.endpoint = endpoint;
        }
        public UUID getAccountId() { return accountId; }
        public void setAccountId(UUID accountId) { this.accountId = accountId; }
        public String getKey() { return key; }
        public void setKey(String key) { this.key = key; }
        public String getEndpoint() { return endpoint; }
        public void setEndpoint(String endpoint) { this.endpoint = endpoint; }
        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            IdempotencyKeyId that = (IdempotencyKeyId) o;
            return java.util.Objects.equals(accountId, that.accountId)
                    && java.util.Objects.equals(key, that.key)
                    && java.util.Objects.equals(endpoint, that.endpoint);
        }
        @Override
        public int hashCode() {
            return java.util.Objects.hash(accountId, key, endpoint);
        }
    }
}
