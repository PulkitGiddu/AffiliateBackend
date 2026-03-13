package com.snatchmart.snatchmart.integration.flipkart;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

/** Flipkart Affiliate API: All Offers response. */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class FlipkartAllOffersResponse {
    @JsonProperty("allOffersList")
    private List<FlipkartOfferDto> allOffersList;
}
