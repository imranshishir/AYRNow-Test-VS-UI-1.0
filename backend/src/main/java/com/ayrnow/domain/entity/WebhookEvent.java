package com.ayrnow.domain.entity;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "webhook_events")
public class WebhookEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "account_id")
    private UUID accountId;

    @Column(name = "stripe_event_id", nullable = false, unique = true)
    private String stripeEventId;

    @Column(nullable = false)
    private String type;

    @Column(name = "received_at", nullable = false, updatable = false)
    private Instant receivedAt;

    @Column(name = "processed_at")
    private Instant processedAt;

    @Column(nullable = false)
    private String status = "received";

    private String error;

    @PrePersist
    protected void onCreate() {
        if (receivedAt == null) receivedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getAccountId() { return accountId; }
    public void setAccountId(UUID accountId) { this.accountId = accountId; }
    public String getStripeEventId() { return stripeEventId; }
    public void setStripeEventId(String stripeEventId) { this.stripeEventId = stripeEventId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public Instant getReceivedAt() { return receivedAt; }
    public void setReceivedAt(Instant receivedAt) { this.receivedAt = receivedAt; }
    public Instant getProcessedAt() { return processedAt; }
    public void setProcessedAt(Instant processedAt) { this.processedAt = processedAt; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getError() { return error; }
    public void setError(String error) { this.error = error; }
}
