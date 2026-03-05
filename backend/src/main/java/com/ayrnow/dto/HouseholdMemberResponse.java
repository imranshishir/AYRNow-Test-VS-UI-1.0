package com.ayrnow.dto;

import java.time.Instant;

public class HouseholdMemberResponse {
    private String id;
    private String unitId;
    private String name;
    private String email;
    private String phone;
    private String role;
    private String status;
    private Instant createdAt;

    public HouseholdMemberResponse(String id, String unitId, String name, String email, String phone, String role, String status, Instant createdAt) {
        this.id = id;
        this.unitId = unitId;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.role = role;
        this.status = status;
        this.createdAt = createdAt;
    }

    public String getId() { return id; }
    public String getUnitId() { return unitId; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    public String getRole() { return role; }
    public String getStatus() { return status; }
    public Instant getCreatedAt() { return createdAt; }
}
