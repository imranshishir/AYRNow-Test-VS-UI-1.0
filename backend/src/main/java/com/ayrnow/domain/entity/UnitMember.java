package com.ayrnow.domain.entity;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "unit_members")
@IdClass(UnitMember.UnitMemberId.class)
public class UnitMember {

    @Id
    @Column(name = "unit_id", nullable = false, updatable = false)
    private UUID unitId;

    @Id
    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;

    @Column(name = "account_id", nullable = false, updatable = false)
    private UUID accountId;

    @Column(nullable = false)
    private String role;

    @Column(name = "added_at", nullable = false, updatable = false)
    private Instant addedAt;

    @PrePersist
    protected void onCreate() {
        if (addedAt == null) {
            addedAt = Instant.now();
        }
    }

    public UUID getUnitId() {
        return unitId;
    }

    public void setUnitId(UUID unitId) {
        this.unitId = unitId;
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

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Instant getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(Instant addedAt) {
        this.addedAt = addedAt;
    }

    public static final class UnitMemberId implements java.io.Serializable {
        private UUID unitId;
        private UUID userId;

        public UnitMemberId() {}

        public UnitMemberId(UUID unitId, UUID userId) {
            this.unitId = unitId;
            this.userId = userId;
        }

        public UUID getUnitId() { return unitId; }
        public void setUnitId(UUID unitId) { this.unitId = unitId; }
        public UUID getUserId() { return userId; }
        public void setUserId(UUID userId) { this.userId = userId; }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            UnitMemberId that = (UnitMemberId) o;
            return java.util.Objects.equals(unitId, that.unitId) && java.util.Objects.equals(userId, that.userId);
        }

        @Override
        public int hashCode() {
            return java.util.Objects.hash(unitId, userId);
        }
    }
}
