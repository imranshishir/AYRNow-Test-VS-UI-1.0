package com.ayrnow.dto;

import jakarta.validation.constraints.NotBlank;

public class CreateTransferRequestRequest {
    @NotBlank
    private String targetEmailOrCode;
    private String note;

    public String getTargetEmailOrCode() { return targetEmailOrCode; }
    public void setTargetEmailOrCode(String targetEmailOrCode) { this.targetEmailOrCode = targetEmailOrCode; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
