package com.ayrnow.dto;

public class LoginResponse {
    private String token;
    private String role;
    private String userId;
    private String email;

    public LoginResponse(String token, String role, String userId, String email) {
        this.token = token;
        this.role = role;
        this.userId = userId;
        this.email = email;
    }

    public String getToken() { return token; }
    public String getRole() { return role; }
    public String getUserId() { return userId; }
    public String getEmail() { return email; }
}
