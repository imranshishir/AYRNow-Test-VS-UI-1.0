package com.ayrnow.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class UpdateTicketStatusRequest {
    @NotBlank
    @Pattern(regexp = "open|in_progress|closed", message = "Must be open, in_progress, or closed")
    private String status;

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
