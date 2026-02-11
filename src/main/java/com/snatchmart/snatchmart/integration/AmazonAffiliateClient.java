package com.snatchmart.snatchmart.integration;

import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;

@Component
public class AmazonAffiliateClient implements AffiliateClient {
    @Override
    public String provider() {
        return "amazon";
    }

    @Override
    public List<AffiliateDeal> fetchLatestDeals() {
        // TODO: Implement Amazon PA-API integration and map response to AffiliateDeal.
        return Collections.emptyList();
    }
}
