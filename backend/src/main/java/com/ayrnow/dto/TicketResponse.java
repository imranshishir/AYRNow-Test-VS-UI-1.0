package com.ayrnow.dto;

import java.time.Instant;

public class TicketResponse {
    private String id;
    private String unit;
    private String title;
    private String priority;
    private Instant createdAt;
    private String status;

    public TicketResponse(String id, String unit, String title, String priority, Instant createdAt, String status) {
        this.id = id;
        this.unit = unit;
        this.title = title;
        this.priority = priority;
        this.createdAt = createdAt;
        this.status = status;
    }

    public String getId() { return id; }
    public String getUnit() { return unit; }
    public String getTitle() { return title; }
    public String getPriority() { return priority; }
    public Instant getCreatedAt() { return createdAt; }
    public String getStatus() { return status; }
}
