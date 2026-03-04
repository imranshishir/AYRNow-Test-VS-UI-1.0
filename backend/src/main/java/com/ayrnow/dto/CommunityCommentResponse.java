package com.ayrnow.dto;

import java.time.Instant;

public class CommunityCommentResponse {
    private String id;
    private String postId;
    private String authorId;
    private String authorName;
    private String body;
    private Instant createdAt;

    public CommunityCommentResponse(String id, String postId, String authorId, String authorName, String body, Instant createdAt) {
        this.id = id;
        this.postId = postId;
        this.authorId = authorId;
        this.authorName = authorName;
        this.body = body;
        this.createdAt = createdAt;
    }

    public String getId() { return id; }
    public String getPostId() { return postId; }
    public String getAuthorId() { return authorId; }
    public String getAuthorName() { return authorName; }
    public String getBody() { return body; }
    public Instant getCreatedAt() { return createdAt; }
}
