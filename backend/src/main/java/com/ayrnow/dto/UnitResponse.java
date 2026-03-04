package com.ayrnow.dto;

public class UnitResponse {
    private String id;
    private String label;
    private String propertyId;

    public UnitResponse(String id, String label, String propertyId) {
        this.id = id;
        this.label = label;
        this.propertyId = propertyId;
    }

    public String getId() { return id; }
    public String getLabel() { return label; }
    public String getPropertyId() { return propertyId; }
}
