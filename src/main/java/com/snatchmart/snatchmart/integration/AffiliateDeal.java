package com.snatchmart.snatchmart.integration;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class AffiliateDeal {
    private String productUniqueId;
    private String productName;
    private String description;
    private BigDecimal originalPrice;
    private BigDecimal salePrice;
    private String affiliateUrl;
    private String imageUrl;
    /** Slug for category (e.g. "deals"). Used when creating new product. */
    private String categorySlug;
    /** Merchant display name (e.g. "Flipkart"). Used when creating new product. */
    private String merchantName;
}
