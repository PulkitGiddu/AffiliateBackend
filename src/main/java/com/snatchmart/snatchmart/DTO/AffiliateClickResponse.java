package com.snatchmart.snatchmart.DTO;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class AffiliateClickResponse {
    private UUID id;
    private UUID userId;
    private UUID productId;
    private UUID merchantId;
    private LocalDateTime clickedAt;
    private String deviceInfo;
    private String ipAddress;
}
