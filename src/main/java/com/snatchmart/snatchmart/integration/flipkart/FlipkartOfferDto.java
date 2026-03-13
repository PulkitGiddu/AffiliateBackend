package com.snatchmart.snatchmart.integration.flipkart;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

/** Flipkart Affiliate API: single offer in DOTD or All Offers response. */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class FlipkartOfferDto {
    private String title;
    private String description;
    private String url;
    private String category;
    private String availability;
    @JsonProperty("imageUrls")
    private List<FlipkartImageDto> imageUrls;
    @JsonProperty("startTime")
    private Long startTime;
    @JsonProperty("endTime")
    private Long endTime;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class FlipkartImageDto {
        private String url;
        private String resolutionType;
    }
}
