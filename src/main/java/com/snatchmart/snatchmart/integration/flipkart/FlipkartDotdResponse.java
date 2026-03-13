package com.snatchmart.snatchmart.integration.flipkart;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

/** Flipkart Affiliate API: Deals of the Day response. */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class FlipkartDotdResponse {
    @JsonProperty("dotdList")
    private List<FlipkartOfferDto> dotdList;
}
