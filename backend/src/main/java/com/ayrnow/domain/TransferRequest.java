package com.ayrnow.domain;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "transfer_requests")
public class TransferRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(name = "tenant_user_id", nullable = false)
    private UUID tenantUserId;
    @Column(name = "target_email_or_code", nullable = false)
    private String targetEmailOrCode;
    private String note;
    @Column(nullable = false)
    private String status;
    @Column(name = "landlord_message", columnDefinition = "TEXT")
    private String landlordMessage;
    @Column(nullable = false)
    private Instant createdAt;
    @Column(name = "decided_at")
    private Instant decidedAt;

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getTenantUserId() { return tenantUserId; }
    public void setTenantUserId(UUID tenantUserId) { this.tenantUserId = tenantUserId; }
    public String getTargetEmailOrCode() { return targetEmailOrCode; }
    public void setTargetEmailOrCode(String targetEmailOrCode) { this.targetEmailOrCode = targetEmailOrCode; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getLandlordMessage() { return landlordMessage; }
    public void setLandlordMessage(String landlordMessage) { this.landlordMessage = landlordMessage; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getDecidedAt() { return decidedAt; }
    public void setDecidedAt(Instant decidedAt) { this.decidedAt = decidedAt; }
}
