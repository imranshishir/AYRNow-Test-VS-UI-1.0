package com.ayrnow.domain.entity;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "post_reactions")
@IdClass(PostReaction.PostReactionId.class)
public class PostReaction {

    @Id
    @Column(name = "post_id", nullable = false, updatable = false)
    private UUID postId;

    @Id
    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;

    @Column(name = "account_id", nullable = false, updatable = false)
    private UUID accountId;

    @Column(nullable = false)
    private String reaction;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = Instant.now();
    }

    public UUID getPostId() { return postId; }
    public void setPostId(UUID postId) { this.postId = postId; }
    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }
    public UUID getAccountId() { return accountId; }
    public void setAccountId(UUID accountId) { this.accountId = accountId; }
    public String getReaction() { return reaction; }
    public void setReaction(String reaction) { this.reaction = reaction; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public static final class PostReactionId implements java.io.Serializable {
        private UUID postId;
        private UUID userId;

        public PostReactionId() {}
        public PostReactionId(UUID postId, UUID userId) { this.postId = postId; this.userId = userId; }
        public UUID getPostId() { return postId; }
        public void setPostId(UUID postId) { this.postId = postId; }
        public UUID getUserId() { return userId; }
        public void setUserId(UUID userId) { this.userId = userId; }
        @Override public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            PostReactionId that = (PostReactionId) o;
            return java.util.Objects.equals(postId, that.postId) && java.util.Objects.equals(userId, that.userId);
        }
        @Override public int hashCode() { return java.util.Objects.hash(postId, userId); }
    }
}
