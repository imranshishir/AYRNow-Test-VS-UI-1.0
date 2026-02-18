package com.ayrnow.domain.entity;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "lease_tenants")
@IdClass(LeaseTenant.LeaseTenantId.class)
public class LeaseTenant {

    @Id
    @Column(name = "lease_id", nullable = false, updatable = false)
    private UUID leaseId;

    @Id
    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;

    @Column(name = "account_id", nullable = false, updatable = false)
    private UUID accountId;

    @Column(name = "added_at", nullable = false, updatable = false)
    private Instant addedAt;

    @PrePersist
    protected void onCreate() {
        if (addedAt == null) {
            addedAt = Instant.now();
        }
    }

    public UUID getLeaseId() {
        return leaseId;
    }

    public void setLeaseId(UUID leaseId) {
        this.leaseId = leaseId;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public UUID getAccountId() {
        return accountId;
    }

    public void setAccountId(UUID accountId) {
        this.accountId = accountId;
    }

    public Instant getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(Instant addedAt) {
        this.addedAt = addedAt;
    }

    public static final class LeaseTenantId implements java.io.Serializable {
        private UUID leaseId;
        private UUID userId;

        public LeaseTenantId() {}

        public LeaseTenantId(UUID leaseId, UUID userId) {
            this.leaseId = leaseId;
            this.userId = userId;
        }

        public UUID getLeaseId() { return leaseId; }
        public void setLeaseId(UUID leaseId) { this.leaseId = leaseId; }
        public UUID getUserId() { return userId; }
        public void setUserId(UUID userId) { this.userId = userId; }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            LeaseTenantId that = (LeaseTenantId) o;
            return java.util.Objects.equals(leaseId, that.leaseId) && java.util.Objects.equals(userId, that.userId);
        }

        @Override
        public int hashCode() {
            return java.util.Objects.hash(leaseId, userId);
        }
    }
}
