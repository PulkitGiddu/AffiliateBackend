package com.snatchmart.snatchmart.scheduler;

import com.snatchmart.snatchmart.service.AffiliateSyncService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class DealScheduler {
    private static final Logger log = LoggerFactory.getLogger(DealScheduler.class);

    private final AffiliateSyncService affiliateSyncService;

    public DealScheduler(AffiliateSyncService affiliateSyncService) {
        this.affiliateSyncService = affiliateSyncService;
    }

    @Scheduled(fixedRate = 30 * 60 * 1000)
    public void syncPrices() {
        log.info("Starting 30-min price sync job");
        affiliateSyncService.syncDeals();
    }

    @Scheduled(cron = "0 0 */6 * * *")
    public void cleanupExpiredDeals() {
        log.info("Starting expired deals cleanup job");
        affiliateSyncService.cleanupExpiredDeals();
    }
}
