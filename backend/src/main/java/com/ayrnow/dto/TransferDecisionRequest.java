package com.ayrnow.dto;

public class TransferDecisionRequest {
    private boolean accept;
    private String landlordMessage;

    public boolean isAccept() { return accept; }
    public void setAccept(boolean accept) { this.accept = accept; }
    public String getLandlordMessage() { return landlordMessage; }
    public void setLandlordMessage(String landlordMessage) { this.landlordMessage = landlordMessage; }
}
