package com.ayrnow.domain.entity;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "tenant_transfer_requests")
public class TenantTransferRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "export_id", nullable = false, updatable = false)
    private UUID exportId;

    @Column(name = "requesting_account_id", nullable = false, updatable = false)
    private UUID requestingAccountId;

    @Column(name = "requesting_user_id", nullable = false, updatable = false)
    private UUID requestingUserId;

    @Column(nullable = false)
    private String status = "pending";

    @Column(name = "requested_at", nullable = false, updatable = false)
    private Instant requestedAt;

    @Column(name = "decided_at")
    private Instant decidedAt;

    @Column(name = "decision_by_user_id")
    private UUID decisionByUserId;

    @PrePersist
    protected void onCreate() {
        if (requestedAt == null) requestedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getExportId() { return exportId; }
    public void setExportId(UUID exportId) { this.exportId = exportId; }
    public UUID getRequestingAccountId() { return requestingAccountId; }
    public void setRequestingAccountId(UUID requestingAccountId) { this.requestingAccountId = requestingAccountId; }
    public UUID getRequestingUserId() { return requestingUserId; }
    public void setRequestingUserId(UUID requestingUserId) { this.requestingUserId = requestingUserId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getRequestedAt() { return requestedAt; }
    public void setRequestedAt(Instant requestedAt) { this.requestedAt = requestedAt; }
    public Instant getDecidedAt() { return decidedAt; }
    public void setDecidedAt(Instant decidedAt) { this.decidedAt = decidedAt; }
    public UUID getDecisionByUserId() { return decisionByUserId; }
    public void setDecisionByUserId(UUID decisionByUserId) { this.decisionByUserId = decisionByUserId; }
}
