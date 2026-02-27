package com.ayrnow.domain.entity;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "tenant_reviews")
public class TenantReview {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "tenant_user_id", nullable = false, updatable = false)
    private UUID tenantUserId;

    @Column(name = "from_account_id", nullable = false, updatable = false)
    private UUID fromAccountId;

    @Column(name = "from_property_id")
    private UUID fromPropertyId;

    @Column(name = "from_unit_id")
    private UUID fromUnitId;

    @Column(nullable = false)
    private int rating;

    @Column(name = "review_text")
    private String reviewText;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getTenantUserId() { return tenantUserId; }
    public void setTenantUserId(UUID tenantUserId) { this.tenantUserId = tenantUserId; }
    public UUID getFromAccountId() { return fromAccountId; }
    public void setFromAccountId(UUID fromAccountId) { this.fromAccountId = fromAccountId; }
    public UUID getFromPropertyId() { return fromPropertyId; }
    public void setFromPropertyId(UUID fromPropertyId) { this.fromPropertyId = fromPropertyId; }
    public UUID getFromUnitId() { return fromUnitId; }
    public void setFromUnitId(UUID fromUnitId) { this.fromUnitId = fromUnitId; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public String getReviewText() { return reviewText; }
    public void setReviewText(String reviewText) { this.reviewText = reviewText; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
