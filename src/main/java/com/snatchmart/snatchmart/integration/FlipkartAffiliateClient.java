package com.snatchmart.snatchmart.integration;

import com.snatchmart.snatchmart.configuration.FlipkartAffiliateConfig;
import com.snatchmart.snatchmart.integration.flipkart.FlipkartAllOffersResponse;
import com.snatchmart.snatchmart.integration.flipkart.FlipkartDotdResponse;
import com.snatchmart.snatchmart.integration.flipkart.FlipkartOfferDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Fetches products and offers from Flipkart Affiliate API (DOTD + All Offers)
 * and maps them to {@link AffiliateDeal}. Persisted by {@link com.snatchmart.snatchmart.service.AffiliateSyncService}.
 * When flipkart.affiliate.id/token are not set, returns dummy deals so the UI has data without credentials.
 */
@Component
public class FlipkartAffiliateClient implements AffiliateClient {
    private static final Logger log = LoggerFactory.getLogger(FlipkartAffiliateClient.class);

    private static final String DOTD_JSON = "https://affiliate-api.flipkart.net/affiliate/offers/v1/dotd/json";
    private static final String ALL_OFFERS_JSON = "https://affiliate-api.flipkart.net/affiliate/offers/v1/all/json";
    private static final String MERCHANT_NAME = "Flipkart";
    private static final String CATEGORY_DEALS = "deals";
    private static final int MAX_ALL_OFFERS = 100;

    private final FlipkartAffiliateConfig config;
    private final RestTemplate restTemplate;

    public FlipkartAffiliateClient(FlipkartAffiliateConfig config, RestTemplate restTemplate) {
        this.config = config;
        this.restTemplate = restTemplate;
    }

    @Override
    public String provider() {
        return "flipkart";
    }

    @Override
    public List<AffiliateDeal> fetchLatestDeals() {
        if (!config.isConfigured()) {
            log.info("Flipkart affiliate not configured; using dummy deals for UI");
            return buildDummyDeals();
        }

        List<AffiliateDeal> deals = new ArrayList<>();

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("Fk-Affiliate-Id", config.getId());
            headers.set("Fk-Affiliate-Token", config.getToken());
            HttpEntity<Void> entity = new HttpEntity<>(headers);

            // 1) Deals of the Day
            ResponseEntity<FlipkartDotdResponse> dotdResponse = restTemplate.exchange(
                    DOTD_JSON,
                    HttpMethod.GET,
                    entity,
                    FlipkartDotdResponse.class
            );
            if (dotdResponse.getBody() != null && dotdResponse.getBody().getDotdList() != null) {
                dotdResponse.getBody().getDotdList().stream()
                        .map(o -> toDeal(o, "dotd"))
                        .forEach(deals::add);
            }

            // 2) All Offers (limit to first N)
            ResponseEntity<FlipkartAllOffersResponse> allResponse = restTemplate.exchange(
                    ALL_OFFERS_JSON,
                    HttpMethod.GET,
                    entity,
                    FlipkartAllOffersResponse.class
            );
            if (allResponse.getBody() != null && allResponse.getBody().getAllOffersList() != null) {
                allResponse.getBody().getAllOffersList().stream()
                        .limit(MAX_ALL_OFFERS)
                        .map(o -> toDeal(o, "offer"))
                        .forEach(deals::add);
            }

            log.info("Fetched {} deals from Flipkart (DOTD + All Offers)", deals.size());
        } catch (Exception e) {
            log.warn("Failed to fetch Flipkart affiliate deals: {}", e.getMessage());
        }

        return deals;
    }

    private AffiliateDeal toDeal(FlipkartOfferDto o, String prefix) {
        String url = o.getUrl() != null ? o.getUrl() : "";
        String productUniqueId = "fk-" + prefix + "-" + Integer.toHexString(url.hashCode());
        String imageUrl = null;
        if (o.getImageUrls() != null && !o.getImageUrls().isEmpty()) {
            imageUrl = o.getImageUrls().stream()
                    .filter(img -> img.getUrl() != null)
                    .findFirst()
                    .map(FlipkartOfferDto.FlipkartImageDto::getUrl)
                    .orElse(null);
        }
        String categorySlug = (o.getCategory() != null && !o.getCategory().isBlank())
                ? o.getCategory().toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("^-|-$", "")
                : CATEGORY_DEALS;
        if (categorySlug.isBlank()) {
            categorySlug = CATEGORY_DEALS;
        }

        return AffiliateDeal.builder()
                .productUniqueId(productUniqueId)
                .productName(o.getTitle() != null ? o.getTitle() : "Deal")
                .description(o.getDescription())
                .originalPrice(null)
                .salePrice(null)
                .affiliateUrl(url)
                .imageUrl(imageUrl)
                .categorySlug(categorySlug)
                .merchantName(MERCHANT_NAME)
                .build();
    }

    /** Dummy deals when Flipkart credentials are not set. Saved to DB and shown in UI. */
    private List<AffiliateDeal> buildDummyDeals() {
        return List.of(
                AffiliateDeal.builder()
                        .productUniqueId("fk-dummy-1")
                        .productName("Wireless Earbuds")
                        .description("Noise cancellation, 20hr battery")
                        .originalPrice(new BigDecimal("2999"))
                        .salePrice(new BigDecimal("1999"))
                        .affiliateUrl("https://www.flipkart.com/")
                        .imageUrl(null)
                        .categorySlug("electronics")
                        .merchantName(MERCHANT_NAME)
                        .build(),
                AffiliateDeal.builder()
                        .productUniqueId("fk-dummy-2")
                        .productName("Smart Watch")
                        .description("Fitness tracking, 7-day battery")
                        .originalPrice(new BigDecimal("4999"))
                        .salePrice(new BigDecimal("3499"))
                        .affiliateUrl("https://www.flipkart.com/")
                        .imageUrl(null)
                        .categorySlug("electronics")
                        .merchantName(MERCHANT_NAME)
                        .build(),
                AffiliateDeal.builder()
                        .productUniqueId("fk-dummy-3")
                        .productName("Backpack")
                        .description("Laptop compartment, water resistant")
                        .originalPrice(new BigDecimal("1299"))
                        .salePrice(new BigDecimal("899"))
                        .affiliateUrl("https://www.flipkart.com/")
                        .imageUrl(null)
                        .categorySlug("deals")
                        .merchantName(MERCHANT_NAME)
                        .build(),
                AffiliateDeal.builder()
                        .productUniqueId("fk-dummy-4")
                        .productName("Power Bank 20000mAh")
                        .description("Fast charging, dual USB")
                        .originalPrice(new BigDecimal("1899"))
                        .salePrice(new BigDecimal("999"))
                        .affiliateUrl("https://www.flipkart.com/")
                        .imageUrl(null)
                        .categorySlug("electronics")
                        .merchantName(MERCHANT_NAME)
                        .build(),
                AffiliateDeal.builder()
                        .productUniqueId("fk-dummy-5")
                        .productName("Running Shoes")
                        .description("Lightweight, cushioned sole")
                        .originalPrice(new BigDecimal("3999"))
                        .salePrice(new BigDecimal("2499"))
                        .affiliateUrl("https://www.flipkart.com/")
                        .imageUrl(null)
                        .categorySlug("deals")
                        .merchantName(MERCHANT_NAME)
                        .build()
        );
    }
}
