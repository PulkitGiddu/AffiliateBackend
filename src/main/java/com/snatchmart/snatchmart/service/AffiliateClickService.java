package com.snatchmart.snatchmart.service;

import com.snatchmart.snatchmart.DTO.AffiliateClickRequest;
import com.snatchmart.snatchmart.DTO.AffiliateClickResponse;

import java.util.UUID;

public interface AffiliateClickService {
    AffiliateClickResponse track(AffiliateClickRequest request);
    AffiliateClickResponse getById(UUID id);
}
