package com.ayrnow.dto;

import java.time.Instant;
import java.util.List;

public class TicketDetailResponse extends TicketResponse {
    private String description;
    private List<CommentResponse> comments;

    public TicketDetailResponse(String id, String unit, String title, String priority, Instant createdAt, String status,
                                String description, List<CommentResponse> comments) {
        super(id, unit, title, priority, createdAt, status);
        this.description = description;
        this.comments = comments;
    }

    public String getDescription() { return description; }
    public List<CommentResponse> getComments() { return comments; }
}
