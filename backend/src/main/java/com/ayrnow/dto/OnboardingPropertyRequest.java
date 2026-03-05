package com.ayrnow.dto;

import jakarta.validation.constraints.NotBlank;

import java.util.List;

public class OnboardingPropertyRequest {
    @NotBlank
    private String name;
    private String address;
    private List<String> units;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public List<String> getUnits() { return units; }
    public void setUnits(List<String> units) { this.units = units; }
}
