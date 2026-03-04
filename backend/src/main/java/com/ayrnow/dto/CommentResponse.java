package com.ayrnow.dto;

import java.time.Instant;

public class CommentResponse {
    private String id;
    private String body;
    private Instant createdAt;
    private String authorName;

    public CommentResponse(String id, String body, Instant createdAt, String authorName) {
        this.id = id;
        this.body = body;
        this.createdAt = createdAt;
        this.authorName = authorName;
    }

    public String getId() { return id; }
    public String getBody() { return body; }
    public Instant getCreatedAt() { return createdAt; }
    public String getAuthorName() { return authorName; }
}
