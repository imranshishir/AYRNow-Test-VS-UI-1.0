package com.ayrnow.dto;

import jakarta.validation.constraints.NotBlank;

import java.util.UUID;

public class CreateCommunityPostRequest {
    @NotBlank
    private String scopeType;
    private UUID scopeId;
    @NotBlank
    private String audience;
    @NotBlank
    private String priority;
    @NotBlank
    private String title;
    @NotBlank
    private String body;

    public String getScopeType() { return scopeType; }
    public void setScopeType(String scopeType) { this.scopeType = scopeType; }
    public UUID getScopeId() { return scopeId; }
    public void setScopeId(UUID scopeId) { this.scopeId = scopeId; }
    public String getAudience() { return audience; }
    public void setAudience(String audience) { this.audience = audience; }
    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }
}
