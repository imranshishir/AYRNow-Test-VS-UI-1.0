package com.ayrnow.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Email;

public class ForgotPasswordRequest {

    @NotBlank(message = "email is required")
    @Email
    private String email;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
