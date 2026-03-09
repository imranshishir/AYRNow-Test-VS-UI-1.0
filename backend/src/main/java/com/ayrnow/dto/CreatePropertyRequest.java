package com.ayrnow.dto;

import jakarta.validation.constraints.NotBlank;

public class CreatePropertyRequest {

    @NotBlank(message = "name is required")
    private String name;
    private String address1;
    private String city;
    private String state;
    private String postalCode;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAddress1() { return address1; }
    public void setAddress1(String address1) { this.address1 = address1; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    public String getPostalCode() { return postalCode; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }
}
