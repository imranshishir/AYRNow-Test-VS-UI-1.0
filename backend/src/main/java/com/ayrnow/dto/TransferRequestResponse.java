package com.ayrnow.dto;

import java.time.Instant;

public class TransferRequestResponse {
    private final String id;
    private final String tenantUserId;
    private final String tenantName;
    private final String targetEmailOrCode;
    private final String note;
    private final String status;
    private final Instant createdAt;
    private final Instant decidedAt;
    private final String landlordMessage;

    public TransferRequestResponse(String id, String tenantUserId, String tenantName,
                                   String targetEmailOrCode, String note, String status,
                                   Instant createdAt, Instant decidedAt, String landlordMessage) {
        this.id = id;
        this.tenantUserId = tenantUserId;
        this.tenantName = tenantName;
        this.targetEmailOrCode = targetEmailOrCode;
        this.note = note;
        this.status = status;
        this.createdAt = createdAt;
        this.decidedAt = decidedAt;
        this.landlordMessage = landlordMessage;
    }

    public String getId() { return id; }
    public String getTenantUserId() { return tenantUserId; }
    public String getTenantName() { return tenantName; }
    public String getTargetEmailOrCode() { return targetEmailOrCode; }
    public String getNote() { return note; }
    public String getStatus() { return status; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getDecidedAt() { return decidedAt; }
    public String getLandlordMessage() { return landlordMessage; }
}
