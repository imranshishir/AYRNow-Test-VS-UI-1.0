package com.ayrnow.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "jwt")
public class JwtProperties {
    private String secret = "change_me_dev_secret";
    private int expirationMinutes = 1440;

    public String getSecret() { return secret; }
    public void setSecret(String secret) { this.secret = secret; }
    public int getExpirationMinutes() { return expirationMinutes; }
    public void setExpirationMinutes(int expirationMinutes) { this.expirationMinutes = expirationMinutes; }
}

