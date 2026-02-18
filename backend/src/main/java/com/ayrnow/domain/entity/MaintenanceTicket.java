package com.ayrnow.domain.entity;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "maintenance_tickets")
public class MaintenanceTicket {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "account_id", nullable = false, updatable = false)
    private UUID accountId;

    @Column(name = "property_id", nullable = false, updatable = false)
    private UUID propertyId;

    @Column(name = "unit_id", nullable = false, updatable = false)
    private UUID unitId;

    @Column(name = "created_by_user_id", nullable = false, updatable = false)
    private UUID createdByUserId;

    @Column(nullable = false)
    private String title;

    private String description;

    @Column(nullable = false)
    private String status = "open";

    @Column(nullable = false)
    private String priority = "medium";

    @Column(name = "assigned_contractor_id")
    private UUID assignedContractorId;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = Instant.now();
        if (updatedAt == null) updatedAt = Instant.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getAccountId() { return accountId; }
    public void setAccountId(UUID accountId) { this.accountId = accountId; }
    public UUID getPropertyId() { return propertyId; }
    public void setPropertyId(UUID propertyId) { this.propertyId = propertyId; }
    public UUID getUnitId() { return unitId; }
    public void setUnitId(UUID unitId) { this.unitId = unitId; }
    public UUID getCreatedByUserId() { return createdByUserId; }
    public void setCreatedByUserId(UUID createdByUserId) { this.createdByUserId = createdByUserId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }
    public UUID getAssignedContractorId() { return assignedContractorId; }
    public void setAssignedContractorId(UUID assignedContractorId) { this.assignedContractorId = assignedContractorId; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
