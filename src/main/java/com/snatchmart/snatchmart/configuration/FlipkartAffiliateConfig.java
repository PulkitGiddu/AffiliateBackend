package com.snatchmart.snatchmart.configuration;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "flipkart.affiliate")
public class FlipkartAffiliateConfig {
    private String id = "";
    private String token = "";

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public boolean isConfigured() {
        return id != null && !id.isBlank() && token != null && !token.isBlank();
    }
}
