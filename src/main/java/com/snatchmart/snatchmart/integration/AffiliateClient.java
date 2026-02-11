package com.snatchmart.snatchmart.integration;

import java.util.List;

public interface AffiliateClient {
    String provider();
    List<AffiliateDeal> fetchLatestDeals();
}
