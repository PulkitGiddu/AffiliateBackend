package com.snatchmart.snatchmart.integration;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Scrapes Flipkart using two strategies:
 * 1. Extracts JSON from the embedded __INITIAL_STATE__ script block (server-side rendered)
 * 2. Falls back to HTML card parsing for any DOM-visible products
 * 3. Falls back to dummy deals if both fail
 */
@Component
public class FlipkartAffiliateClient implements AffiliateClient {

    private static final Logger log = LoggerFactory.getLogger(FlipkartAffiliateClient.class);

    private static final String MERCHANT_NAME = "Flipkart";
    private static final String BASE_URL = "https://www.flipkart.com";

    // Search pages — SSR-friendly, embed product JSON in <script> tags
    private static final List<String[]> SCRAPE_TARGETS = List.of(
            new String[]{"https://www.flipkart.com/search?q=headphones&sort=popularity", "electronics"},
            new String[]{"https://www.flipkart.com/search?q=smartwatch&sort=relevance", "electronics"},
            new String[]{"https://www.flipkart.com/search?q=running+shoes&sort=popularity", "fashion"},
            new String[]{"https://www.flipkart.com/search?q=power+bank&sort=popularity", "electronics"},
            new String[]{"https://www.flipkart.com/search?q=bluetooth+speaker&sort=popularity", "electronics"}
    );

    private static final Pattern INITIAL_STATE_PATTERN = Pattern.compile(
            "window\\.__INITIAL_STATE__\\s*=\\s*(\\{.+?\\});?\\s*(?:window|</script)",
            Pattern.DOTALL
    );

    private final ProxyRotator proxyRotator;
    private final ScraperConfig scraperConfig;
    private final ObjectMapper objectMapper;

    public FlipkartAffiliateClient(ProxyRotator proxyRotator, ScraperConfig scraperConfig) {
        this.proxyRotator = proxyRotator;
        this.scraperConfig = scraperConfig;
        this.objectMapper = new ObjectMapper();
    }

    @Override
    public String provider() {
        return "flipkart";
    }

    @Override
    public List<AffiliateDeal> fetchLatestDeals() {
        List<AffiliateDeal> deals = new ArrayList<>();

        for (String[] target : SCRAPE_TARGETS) {
            String url = target[0];
            String categorySlug = target[1];
            try {
                Document doc = proxyRotator.connect(url).get();

                // Strategy 1: parse embedded JSON state
                List<AffiliateDeal> fromJson = parseEmbeddedJson(doc, categorySlug);
                if (!fromJson.isEmpty()) {
                    deals.addAll(fromJson);
                    log.info("[Flipkart Scraper] Parsed {} deals (JSON) from: {}", fromJson.size(), url);
                } else {
                    // Strategy 2: parse visible HTML product cards
                    List<AffiliateDeal> fromHtml = parseHtmlCards(doc, categorySlug);
                    deals.addAll(fromHtml);
                    log.info("[Flipkart Scraper] Parsed {} deals (HTML) from: {}", fromHtml.size(), url);
                }

                if (deals.size() >= scraperConfig.getMaxProductsPerRun()) break;
                proxyRotator.throttle();
            } catch (Exception e) {
                log.warn("[Flipkart Scraper] Failed to scrape {}: {}", url, e.getMessage());
            }
        }

        if (deals.isEmpty()) {
            log.warn("[Flipkart Scraper] No deals scraped — using dummy fallback");
            return buildDummyDeals();
        }

        log.info("[Flipkart Scraper] Total deals scraped: {}", deals.size());
        return deals;
    }

    // ─── Strategy 1: extract from embedded JSON ───────────────────────────────

    private List<AffiliateDeal> parseEmbeddedJson(Document doc, String defaultCategorySlug) {
        List<AffiliateDeal> deals = new ArrayList<>();
        try {
            Elements scripts = doc.select("script");
            for (Element script : scripts) {
                String content = script.html();
                if (!content.contains("productUrl") && !content.contains("INITIAL_STATE")) continue;

                Matcher m = INITIAL_STATE_PATTERN.matcher(content);
                if (m.find()) {
                    JsonNode root = objectMapper.readTree(m.group(1));
                    extractDealsFromJsonNode(root, deals, defaultCategorySlug);
                    if (!deals.isEmpty()) break;
                }

                // Also try inline JSON product arrays
                if (content.contains("\"productUrl\"")) {
                    try {
                        JsonNode node = objectMapper.readTree(content.trim());
                        extractDealsFromJsonNode(node, deals, defaultCategorySlug);
                    } catch (Exception ignored) {}
                }
            }
        } catch (Exception e) {
            log.debug("[Flipkart Scraper] JSON parse failed: {}", e.getMessage());
        }
        return deals;
    }

    private void extractDealsFromJsonNode(JsonNode root, List<AffiliateDeal> deals, String defaultCategorySlug) {
        root.findValues("productUrl").forEach(urlNode -> {
            try {
                String productPath = urlNode.asText();
                if (productPath == null || productPath.isBlank()) return;
                String url = productPath.startsWith("http") ? productPath : BASE_URL + productPath;

                // Walk up to find parent node with pricing info
                JsonNode parent = findAncestorWithField(root, "productUrl", productPath);
                if (parent == null) return;

                String name = getTextSafe(parent, "title", "name", "productName");
                if (name == null) return;

                BigDecimal salePrice = getPriceSafe(parent, "finalPrice", "price", "discountedPrice");
                BigDecimal origPrice = getPriceSafe(parent, "mrp", "originalPrice", "basePrice");
                if (salePrice == null) return;
                if (origPrice == null) origPrice = salePrice;

                String imageUrl = getTextSafe(parent, "imageUrl", "image", "imgUrl");
                String uniqueId = "fk-scrape-" + Integer.toHexString(url.hashCode());

                deals.add(AffiliateDeal.builder()
                        .productUniqueId(uniqueId)
                        .productName(name.trim())
                        .description(name.trim())
                        .originalPrice(origPrice)
                        .salePrice(salePrice)
                        .affiliateUrl(url)
                        .imageUrl(imageUrl)
                        .categorySlug(inferCategorySlug(url, defaultCategorySlug))
                        .merchantName(MERCHANT_NAME)
                        .build());
            } catch (Exception ignored) {}
        });
    }

    // ─── Strategy 2: parse visible HTML cards ─────────────────────────────────

    private List<AffiliateDeal> parseHtmlCards(Document doc, String defaultCategorySlug) {
        List<AffiliateDeal> deals = new ArrayList<>();

        Elements cards = doc.select("div[data-id]");
        if (cards.isEmpty()) cards = doc.select("div._1AtVbE, div.tUxRFH, div._2kHMtA");
        if (cards.isEmpty()) cards = doc.select("div.IRpwTa, div._4ddWXP");

        for (Element card : cards) {
            try {
                String name = textOrNull(card, "div.KzDlHZ, div._4rR01T, a.s1Q9rs, div.WKTcLC");
                if (name == null || name.isBlank()) continue;

                String href = attrOrNull(card, "a[href]", "href");
                if (href == null) continue;
                String productUrl = href.startsWith("http") ? href : BASE_URL + href;

                String salePriceText = textOrNull(card, "div.Nx9bqj, div._30jeq3, div._1_WHN1");
                String origPriceText = textOrNull(card, "div.yRaY8j, div._3I9_wc");

                BigDecimal salePrice = parsePrice(salePriceText);
                BigDecimal origPrice = parsePrice(origPriceText);
                if (salePrice == null) continue;
                if (origPrice == null) origPrice = salePrice;

                String imageUrl = attrOrNull(card, "img", "src");
                String uniqueId = "fk-scrape-" + Integer.toHexString(productUrl.hashCode());

                deals.add(AffiliateDeal.builder()
                        .productUniqueId(uniqueId)
                        .productName(name.trim())
                        .description(name.trim())
                        .originalPrice(origPrice)
                        .salePrice(salePrice)
                        .affiliateUrl(productUrl)
                        .imageUrl(imageUrl)
                        .categorySlug(inferCategorySlug(productUrl, defaultCategorySlug))
                        .merchantName(MERCHANT_NAME)
                        .build());

                if (deals.size() >= scraperConfig.getMaxProductsPerRun()) break;
            } catch (Exception ignored) {}
        }
        return deals;
    }

    // ─── JSON tree helpers ────────────────────────────────────────────────────

    private JsonNode findAncestorWithField(JsonNode root, String field, String value) {
        if (root.isObject()) {
            if (root.has(field) && root.get(field).asText().equals(value)) return root;
            for (JsonNode child : root) {
                JsonNode result = findAncestorWithField(child, field, value);
                if (result != null) return result;
            }
        } else if (root.isArray()) {
            for (JsonNode item : root) {
                JsonNode result = findAncestorWithField(item, field, value);
                if (result != null) return result;
            }
        }
        return null;
    }

    private String getTextSafe(JsonNode node, String... fields) {
        for (String f : fields) {
            if (node.has(f) && !node.get(f).isNull() && !node.get(f).asText().isBlank()) {
                return node.get(f).asText();
            }
        }
        return null;
    }

    private BigDecimal getPriceSafe(JsonNode node, String... fields) {
        for (String f : fields) {
            if (node.has(f)) {
                try {
                    String val = node.get(f).asText().replaceAll("[^0-9.]", "");
                    if (!val.isBlank()) return new BigDecimal(val);
                } catch (Exception ignored) {}
            }
        }
        return null;
    }

    // ─── Shared helpers ───────────────────────────────────────────────────────

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
        if (url.contains("headphone") || url.contains("smartwatch") || url.contains("mobile")
                || url.contains("power") || url.contains("speaker") || url.contains("electronics")) return "electronics";
        if (url.contains("shoes") || url.contains("clothing") || url.contains("fashion")) return "fashion";
        if (url.contains("home") || url.contains("kitchen")) return "home-kitchen";
        if (url.contains("books")) return "books";
        return defaultSlug;
    }

    // ─── Dummy fallback ───────────────────────────────────────────────────────

    private List<AffiliateDeal> buildDummyDeals() {
        return List.of(
                deal("fk-dummy-1", "Wireless Earbuds", "Noise cancellation, 20hr battery", 2999, 1999, "electronics"),
                deal("fk-dummy-2", "Smart Watch", "Fitness tracking, 7-day battery", 4999, 3499, "electronics"),
                deal("fk-dummy-3", "Backpack", "Laptop compartment, water resistant", 1299, 899, "fashion"),
                deal("fk-dummy-4", "Power Bank 20000mAh", "Fast charging, dual USB", 1899, 999, "electronics"),
                deal("fk-dummy-5", "Running Shoes", "Lightweight, cushioned sole", 3999, 2499, "fashion")
        );
    }

    private AffiliateDeal deal(String uid, String name, String desc, int orig, int sale, String cat) {
        return AffiliateDeal.builder()
                .productUniqueId(uid)
                .productName(name)
                .description(desc)
                .originalPrice(new BigDecimal(orig))
                .salePrice(new BigDecimal(sale))
                .affiliateUrl(BASE_URL + "/")
                .imageUrl(null)
                .categorySlug(cat)
                .merchantName(MERCHANT_NAME)
                .build();
    }
}
