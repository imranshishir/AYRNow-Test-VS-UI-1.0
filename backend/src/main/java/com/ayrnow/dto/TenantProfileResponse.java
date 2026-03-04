package com.ayrnow.dto;

import java.time.Instant;
import java.util.List;

public class TenantProfileResponse {
    private String id;
    private String tenantId;
    private String fullName;
    private String phone;
    private String email;
    private String currentAddress;
    private List<OccupancyRecordResponse> occupancyHistory;
    private int paymentScore;
    private List<TenantReviewResponse> reviews;
    private List<ProfileDocumentResponse> documents;
    private Instant createdAt;

    public TenantProfileResponse(String id, String tenantId, String fullName, String phone, String email, String currentAddress,
                                 List<OccupancyRecordResponse> occupancyHistory, int paymentScore,
                                 List<TenantReviewResponse> reviews, List<ProfileDocumentResponse> documents, Instant createdAt) {
        this.id = id;
        this.tenantId = tenantId;
        this.fullName = fullName;
        this.phone = phone;
        this.email = email;
        this.currentAddress = currentAddress;
        this.occupancyHistory = occupancyHistory;
        this.paymentScore = paymentScore;
        this.reviews = reviews;
        this.documents = documents;
        this.createdAt = createdAt;
    }

    public String getId() { return id; }
    public String getTenantId() { return tenantId; }
    public String getFullName() { return fullName; }
    public String getPhone() { return phone; }
    public String getEmail() { return email; }
    public String getCurrentAddress() { return currentAddress; }
    public List<OccupancyRecordResponse> getOccupancyHistory() { return occupancyHistory; }
    public int getPaymentScore() { return paymentScore; }
    public List<TenantReviewResponse> getReviews() { return reviews; }
    public List<ProfileDocumentResponse> getDocuments() { return documents; }
    public Instant getCreatedAt() { return createdAt; }

    public record OccupancyRecordResponse(String propertyName, String unitLabel, Instant startDate, Instant endDate, String landlordName) {}
    public record TenantReviewResponse(String id, String reviewerName, int rating, String comment, Instant createdAt) {}
    public record ProfileDocumentResponse(String id, String type, String filename, String status) {}
}
