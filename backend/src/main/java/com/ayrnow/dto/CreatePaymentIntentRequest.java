package com.ayrnow.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public class CreatePaymentIntentRequest {
    @NotNull
    private UUID unitId;
    /**
     * Optional amount in dollars; converted to cents on the backend when provided.
     */
    private Integer amount;
    /**
     * Optional raw amount in cents; takes precedence over {@code amount} when set.
     */
    private Integer amountCents;
    /**
     * Optional ISO currency code; defaults to "usd" when blank.
     */
    private String currency;

    public UUID getUnitId() { return unitId; }
    public void setUnitId(UUID unitId) { this.unitId = unitId; }
    public Integer getAmount() { return amount; }
    public void setAmount(Integer amount) { this.amount = amount; }
    public Integer getAmountCents() { return amountCents; }
    public void setAmountCents(Integer amountCents) { this.amountCents = amountCents; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
}
