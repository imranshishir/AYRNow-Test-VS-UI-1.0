package com.ayrnow.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "ayrnow")
public class AppUrlProperties {

    private String appBaseUrl = "http://localhost:8080";

    public String getAppBaseUrl() { return appBaseUrl; }
    public void setAppBaseUrl(String appBaseUrl) { this.appBaseUrl = appBaseUrl != null ? appBaseUrl : "http://localhost:8080"; }
}
