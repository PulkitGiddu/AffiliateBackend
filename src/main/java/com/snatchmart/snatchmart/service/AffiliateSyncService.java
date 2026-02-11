package com.snatchmart.snatchmart.service;

public interface AffiliateSyncService {
    void syncDeals();
    void cleanupExpiredDeals();
}
