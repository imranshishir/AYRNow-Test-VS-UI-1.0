package com.ayrnow.dto;

import java.time.Instant;

public class CommunityPostResponse {
    private String id;
    private String scopeType;
    private String scopeId;
    private String authorId;
    private String authorName;
    private String authorRole;
    private String title;
    private String body;
    private String priority;
    private String audience;
    private int commentCount;
    private Instant createdAt;

    public CommunityPostResponse(String id, String scopeType, String scopeId, String authorId, String authorName, String authorRole,
                                 String title, String body, String priority, String audience, int commentCount, Instant createdAt) {
        this.id = id;
        this.scopeType = scopeType;
        this.scopeId = scopeId;
        this.authorId = authorId;
        this.authorName = authorName;
        this.authorRole = authorRole;
        this.title = title;
        this.body = body;
        this.priority = priority;
        this.audience = audience;
        this.commentCount = commentCount;
        this.createdAt = createdAt;
    }

    public String getId() { return id; }
    public String getScopeType() { return scopeType; }
    public String getScopeId() { return scopeId; }
    public String getAuthorId() { return authorId; }
    public String getAuthorName() { return authorName; }
    public String getAuthorRole() { return authorRole; }
    public String getTitle() { return title; }
    public String getBody() { return body; }
    public String getPriority() { return priority; }
    public String getAudience() { return audience; }
    public int getCommentCount() { return commentCount; }
    public Instant getCreatedAt() { return createdAt; }
}
