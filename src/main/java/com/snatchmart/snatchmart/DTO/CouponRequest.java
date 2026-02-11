package com.snatchmart.snatchmart.DTO;

import com.snatchmart.snatchmart.entity.DiscountType;
import lombok.Data;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data
public class CouponRequest {
    private String code;
    private String description;
    private DiscountType discountType;
    private BigDecimal discountValue;
    private OffsetDateTime expiryAt;
    private UUID merchantId;
    private Boolean isActive;
}
