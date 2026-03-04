package com.ayrnow.dto;

public class PaymentIntentResponse {
    private String paymentId;
    private String status;
    private String clientSecret;

    public PaymentIntentResponse(String paymentId, String status) {
        this.paymentId = paymentId;
        this.status = status;
        this.clientSecret = null;
    }

    public PaymentIntentResponse(String paymentId, String status, String clientSecret) {
        this.paymentId = paymentId;
        this.status = status;
        this.clientSecret = clientSecret;
    }

    public String getPaymentId() { return paymentId; }
    public String getStatus() { return status; }
    public String getClientSecret() { return clientSecret; }
}
