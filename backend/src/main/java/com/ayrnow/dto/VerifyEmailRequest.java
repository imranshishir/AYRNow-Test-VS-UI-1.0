package com.ayrnow.dto;

import jakarta.validation.constraints.NotBlank;

public class VerifyEmailRequest {

    @NotBlank(message = "token is required")
    private String token;

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
}
