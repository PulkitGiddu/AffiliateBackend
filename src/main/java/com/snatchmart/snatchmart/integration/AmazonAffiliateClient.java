package com.snatchmart.snatchmart.integration;

import com.snatchmart.snatchmart.integration.scraper.ProxyRotator;
import com.snatchmart.snatchmart.integration.scraper.ScraperConfig;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Scrapes real product deals from Amazon India using Jsoup + optional proxy rotation.
 * Falls back to empty list if scraping fails since we don't want Amazon-specific dummies.
 *
 * Pages scraped:
 *  1. Today's Deals: https://www.amazon.in/deals
 *  2. Electronics Best Sellers: https://www.amazon.in/gp/bestsellers/electronics
 *  3. Mobile Best Sellers: https://www.amazon.in/gp/bestsellers/electronics/1389401031
 */
@Component
public class AmazonAffiliateClient implements AffiliateClient {

    private static final Logger log = LoggerFactory.getLogger(AmazonAffiliateClient.class);

    private static final String MERCHANT_NAME = "Amazon";
    private static final String BASE_URL = "https://www.amazon.in";

    private static final List<String[]> SCRAPE_TARGETS = List.of(
            new String[]{"https://www.amazon.in/deals", "deals"},
            new String[]{"https://www.amazon.in/gp/bestsellers/electronics", "electronics"},
            new String[]{"https://www.amazon.in/gp/bestsellers/apparel", "fashion"},
            new String[]{"https://www.amazon.in/gp/bestsellers/home-improvement", "home-kitchen"}
    );

    private final ProxyRotator proxyRotator;
    private final ScraperConfig scraperConfig;

    public AmazonAffiliateClient(ProxyRotator proxyRotator, ScraperConfig scraperConfig) {
        this.proxyRotator = proxyRotator;
        this.scraperConfig = scraperConfig;
    }

    @Override
    public String provider() {
        return "amazon";
    }

    @Override
    public List<AffiliateDeal> fetchLatestDeals() {
        List<AffiliateDeal> deals = new ArrayList<>();
        int errors = 0;

        for (String[] target : SCRAPE_TARGETS) {
            String url = target[0];
            String categorySlug = target[1];
            try {
                List<AffiliateDeal> scraped = scrapePage(url, categorySlug);
                deals.addAll(scraped);
                log.info("[Amazon Scraper] Scraped {} deals from {}", scraped.size(), url);
                if (deals.size() >= scraperConfig.getMaxProductsPerRun()) break;
                proxyRotator.throttle();
            } catch (Exception e) {
                errors++;
                log.warn("[Amazon Scraper] Failed to scrape {}: {}", url, e.getMessage());
            }
        }

        if (deals.isEmpty() && errors > 0) {
            log.warn("[Amazon Scraper] All pages failed ({} errors) — returning empty list", errors);
        } else {
            log.info("[Amazon Scraper] Total deals scraped: {}", deals.size());
        }

        return deals;
    }

    // ─── Scraping logic ───────────────────────────────────────────────────────

    private List<AffiliateDeal> scrapePage(String url, String defaultCategorySlug) throws Exception {
        Document doc = proxyRotator.connect(url).get();
        List<AffiliateDeal> deals = new ArrayList<>();

        // Amazon best sellers layout
        Elements cards = doc.select("div.p13n-sc-uncoverable-faceout, div[id^=gridItemRoot], div.a-cardui, li.zg-item-immersion");

        // Today's deals layout
        if (cards.isEmpty()) {
            cards = doc.select("div[data-testid='product-card'], div.DealCard-module__card, div.a-carousel-card");
        }

        // Generic product link fallback
        if (cards.isEmpty()) {
            cards = doc.select("div.sg-col-inner");
        }

        for (Element card : cards) {
            AffiliateDeal deal = parseProductCard(card, defaultCategorySlug);
            if (deal != null) {
                deals.add(deal);
            }
            if (deals.size() >= scraperConfig.getMaxProductsPerRun()) break;
        }

        return deals;
    }

    private AffiliateDeal parseProductCard(Element card, String defaultCategorySlug) {
        try {
            // Product name
            String name = textOrNull(card, "div.p13n-sc-truncate-desktop-type2, div._cDEzb_p13n-sc-css-line-clamp-1_1Fn1y, span.a-size-medium, span.a-size-base-plus, span.zg-bdg-text");
            if (name == null) name = textOrNull(card, "span.a-text-normal, div.a-section span");
            if (name == null || name.isBlank()) return null;

            // Product URL
            String href = attrOrNull(card, "a.a-link-normal[href], a[href]", "href");
            if (href == null) return null;
            String productUrl = href.startsWith("http") ? href : BASE_URL + href;
            // Filter out non-product links
            if (!productUrl.contains("/dp/") && !productUrl.contains("/gp/") && !productUrl.contains("/deal/")) return null;

            // Prices
            String salePriceText = textOrNull(card, "span.a-price-whole, span._cDEzb_p13n-sc-price_3mJ9Z, span.a-offscreen");
            String originalPriceText = textOrNull(card, "span.a-price.a-text-price span.a-offscreen");

            BigDecimal salePrice = parsePrice(salePriceText);
            BigDecimal originalPrice = parsePrice(originalPriceText);
            if (salePrice == null) salePrice = BigDecimal.ZERO;
            if (originalPrice == null) originalPrice = salePrice;

            // Image
            String imageUrl = attrOrNull(card, "img.a-dynamic-image, img", "src");
            if (imageUrl == null) imageUrl = attrOrNull(card, "img", "data-src");

            // Stable unique ID
            String uniqueId = "amz-scrape-" + Integer.toHexString(productUrl.hashCode());

            String categorySlug = inferCategorySlug(productUrl, defaultCategorySlug);

            return AffiliateDeal.builder()
                    .productUniqueId(uniqueId)
                    .productName(name.trim())
                    .description(name.trim())
                    .originalPrice(originalPrice)
                    .salePrice(salePrice)
                    .affiliateUrl(productUrl)
                    .imageUrl(imageUrl)
                    .categorySlug(categorySlug)
                    .merchantName(MERCHANT_NAME)
                    .build();

        } catch (Exception e) {
            log.debug("[Amazon Scraper] Skipping card: {}", e.getMessage());
            return null;
        }
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private String textOrNull(Element parent, String cssQuery) {
        Element el = parent.selectFirst(cssQuery);
        return el != null ? el.text() : null;
    }

    private String attrOrNull(Element parent, String cssQuery, String attr) {
        Element el = parent.selectFirst(cssQuery);
        return el != null && !el.attr(attr).isBlank() ? el.attr(attr) : null;
    }

    private BigDecimal parsePrice(String text) {
        if (text == null || text.isBlank()) return null;
        try {
            String cleaned = text.replaceAll("[^0-9.]", "");
            return cleaned.isBlank() ? null : new BigDecimal(cleaned);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String inferCategorySlug(String url, String defaultSlug) {
        if (url.contains("electronics") || url.contains("computers") || url.contains("camera")) return "electronics";
        if (url.contains("apparel") || url.contains("clothing") || url.contains("shoes")) return "fashion";
        if (url.contains("home") || url.contains("kitchen") || url.contains("furniture")) return "home-kitchen";
        if (url.contains("books") || url.contains("stationery")) return "books";
        if (url.contains("sports") || url.contains("fitness") || url.contains("outdoor")) return "sports";
        if (url.contains("beauty") || url.contains("health")) return "health-beauty";
        return defaultSlug;
    }
}
