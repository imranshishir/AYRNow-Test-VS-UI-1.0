package com.ayrnow.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "auth")
public class AuthProperties {

    private Jwt jwt = new Jwt();
    private Refresh refresh = new Refresh();
    private boolean devHeadersEnabled = false;

    public static class Jwt {
        private String secret = "dev-secret-change-in-production-min-32-chars";
        private int accessMinutes = 15;

        public String getSecret() { return secret; }
        public void setSecret(String secret) { this.secret = secret; }
        public int getAccessMinutes() { return accessMinutes; }
        public void setAccessMinutes(int accessMinutes) { this.accessMinutes = accessMinutes; }
    }

    public static class Refresh {
        private int days = 30;

        public int getDays() { return days; }
        public void setDays(int days) { this.days = days; }
    }

    public Jwt getJwt() { return jwt; }
    public void setJwt(Jwt jwt) { this.jwt = jwt; }
    public Refresh getRefresh() { return refresh; }
    public void setRefresh(Refresh refresh) { this.refresh = refresh; }
    public boolean isDevHeadersEnabled() { return devHeadersEnabled; }
    public void setDevHeadersEnabled(boolean devHeadersEnabled) { this.devHeadersEnabled = devHeadersEnabled; }
}
