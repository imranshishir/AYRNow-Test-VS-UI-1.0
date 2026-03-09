package com.ayrnow.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "ses")
public class SesProperties {

    private String region = "us-east-1";
    private String fromEmail = "";
    private String fromName = "AYRNOW";

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }
    public String getFromEmail() { return fromEmail; }
    public void setFromEmail(String fromEmail) { this.fromEmail = fromEmail != null ? fromEmail : ""; }
    public String getFromName() { return fromName; }
    public void setFromName(String fromName) { this.fromName = fromName != null ? fromName : "AYRNOW"; }

    public boolean isConfigured() {
        return fromEmail != null && !fromEmail.isBlank();
    }
}
