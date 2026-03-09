package com.ayrnow.dto;

public class RegisterResponse {

    private final String message;
    private final boolean emailSent;

    public RegisterResponse(String message, boolean emailSent) {
        this.message = message;
        this.emailSent = emailSent;
    }

    public String getMessage() { return message; }
    public boolean isEmailSent() { return emailSent; }
}
