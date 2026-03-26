package com.snatchmart.snatchmart.integration.scraper;

import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.URI;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Round-robin proxy rotator for Jsoup connections.
 * Picks the next proxy from the pool on each call.
 * Falls back to a direct connection if no proxies are configured.
 */
@Component
public class ProxyRotator {

    private static final Logger log = LoggerFactory.getLogger(ProxyRotator.class);

    /** Realistic browser User-Agent strings to rotate through */
    private static final List<String> USER_AGENTS = List.of(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0",
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3 Safari/605.1.15"
    );

    private final ScraperConfig config;
    private final AtomicInteger proxyIndex = new AtomicInteger(0);
    private final AtomicInteger uaIndex = new AtomicInteger(0);

    public ProxyRotator(ScraperConfig config) {
        this.config = config;
    }

    /**
     * Build a Jsoup connection to the given URL, optionally routing through
     * the next proxy in the rotation pool and setting a random User-Agent.
     */
    public Connection connect(String url) {
        Connection conn = Jsoup.connect(url)
                .timeout(config.getTimeoutMs())
                .userAgent(nextUserAgent())
                .header("Accept-Language", "en-IN,en;q=0.9")
                .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
                .header("Accept-Encoding", "gzip, deflate, br")
                .followRedirects(true)
                .ignoreHttpErrors(true);

        if (config.hasProxies()) {
            String proxyUrl = nextProxy();
            Proxy proxy = buildProxy(proxyUrl);
            if (proxy != null) {
                conn.proxy(proxy);
                log.debug("Using proxy: {}", maskProxy(proxyUrl));
            }
        }

        return conn;
    }

    /** Sleep between requests to respect rate limits. */
    public void throttle() {
        try {
            int delay = config.getRequestDelayMs();
            if (delay > 0) {
                Thread.sleep(delay);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    // ─── Internal helpers ─────────────────────────────────────────────────────

    private String nextUserAgent() {
        int idx = uaIndex.getAndIncrement() % USER_AGENTS.size();
        return USER_AGENTS.get(idx);
    }

    private String nextProxy() {
        List<String> proxies = config.getProxyList();
        int idx = proxyIndex.getAndIncrement() % proxies.size();
        return proxies.get(idx).trim();
    }

    private Proxy buildProxy(String proxyUrl) {
        try {
            URI uri = URI.create(proxyUrl);
            int port = uri.getPort() > 0 ? uri.getPort() : 8080;
            return new Proxy(Proxy.Type.HTTP, new InetSocketAddress(uri.getHost(), port));
        } catch (Exception e) {
            log.warn("Invalid proxy URL '{}': {}", maskProxy(proxyUrl), e.getMessage());
            return null;
        }
    }

    /** Mask credentials in proxy URL for logging: http://user:****@host:port */
    private String maskProxy(String proxyUrl) {
        if (proxyUrl == null) return "null";
        return proxyUrl.replaceAll("://[^@]+@", "://****@");
    }
}
