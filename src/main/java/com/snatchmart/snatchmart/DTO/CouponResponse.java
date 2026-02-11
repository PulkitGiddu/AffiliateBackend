package com.snatchmart.snatchmart.DTO;

import com.snatchmart.snatchmart.entity.DiscountType;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
public class CouponResponse {
    private UUID id;
    private String code;
    private String description;
    private DiscountType discountType;
    private BigDecimal discountValue;
    private OffsetDateTime expiryAt;
    private UUID merchantId;
    private Boolean isActive;
}
