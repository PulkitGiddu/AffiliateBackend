package com.snatchmart.snatchmart.DTO;

import lombok.Data;

import java.util.UUID;

@Data
public class AffiliateClickRequest {
    private UUID userId;
    private UUID productId;
    private UUID merchantId;
    private String deviceInfo;
    private String ipAddress;
}
