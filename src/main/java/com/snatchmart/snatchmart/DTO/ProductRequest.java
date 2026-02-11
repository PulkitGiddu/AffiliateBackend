package com.snatchmart.snatchmart.DTO;

import lombok.Data;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data
public class ProductRequest {
    private String productName;
    private String description;
    private String productUniqueId;
    private BigDecimal originalPrice;
    private BigDecimal salePrice;
    private Double reviewScore;
    private Integer reviewCount;
    private String affiliateUrl;
    private String imageUrl;
    private UUID merchantId;
    private UUID categoryId;
    private Boolean isActive;
    private OffsetDateTime dealsExpiresAt;
}
