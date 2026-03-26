package com.snatchmart.snatchmart.integration.scraper;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Configuration for the web scraper.
 * Proxy list format: http://user:pass@host:port,http://user:pass@host:port
 * Leave scraper.proxy.list blank to scrape without a proxy (direct connection).
 */
@Component
@Getter
public class ScraperConfig {

    /** Comma-separated list of HTTP proxy URLs. Empty = no proxy. */
    @Value("${scraper.proxy.list:}")
    private String rawProxyList;

    /** Whether to enable proxy rotation. If false, uses direct connection. */
    @Value("${scraper.proxy.enabled:false}")
    private boolean proxyEnabled;

    /** Delay between requests in milliseconds to avoid rate limiting. */
    @Value("${scraper.request.delay-ms:2000}")
    private int requestDelayMs;

    /** Jsoup connection timeout in milliseconds. */
    @Value("${scraper.request.timeout-ms:15000}")
    private int timeoutMs;

    /** Max products to scrape per provider per run. */
    @Value("${scraper.max-products-per-run:50}")
    private int maxProductsPerRun;

    public List<String> getProxyList() {
        if (rawProxyList == null || rawProxyList.isBlank()) {
            return Collections.emptyList();
        }
        return Arrays.asList(rawProxyList.split(","));
    }

    public boolean hasProxies() {
        return proxyEnabled && !getProxyList().isEmpty();
    }
}
