package com.ayrnow.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.LocalDate;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class RentBoardItemResponse {
    private String unitId;
    private String unit;
    private String tenantName;
    private double amountDue;
    private LocalDate dueDate;
    private String status;

    public RentBoardItemResponse(String unitId, String unitLabel, String tenantName, int amountDueCents, LocalDate dueDate, String status) {
        this.unitId = unitId;
        this.unit = unitLabel;
        this.tenantName = tenantName;
        this.amountDue = amountDueCents / 100.0;
        this.dueDate = dueDate;
        this.status = status;
    }

    public String getUnitId() { return unitId; }
    public String getUnit() { return unit; }
    public String getTenantName() { return tenantName; }
    public double getAmountDue() { return amountDue; }
    public LocalDate getDueDate() { return dueDate; }
    public String getStatus() { return status; }
}
