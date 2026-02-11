package com.snatchmart.snatchmart.integration;

import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;

@Component
public class FlipkartAffiliateClient implements AffiliateClient {
    @Override
    public String provider() {
        return "flipkart";
    }

    @Override
    public List<AffiliateDeal> fetchLatestDeals() {
        // TODO: Implement Flipkart affiliate feed integration and map response to AffiliateDeal.
        return Collections.emptyList();
    }
}
