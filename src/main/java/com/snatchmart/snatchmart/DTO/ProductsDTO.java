package com.snatchmart.snatchmart.DTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductsDTO {
    private UUID id;
    private String product_name;
    private String description;
    private String product_unique_id;
    private BigDecimal original_price;
    private BigDecimal sale_price;
    private Double review_score;
    private Integer review_count;
    private String affiliate_url;
    private String image_url;
    private UUID merchant_id;
    private UUID category_id;
    private Boolean is_active;
    private OffsetDateTime deals_expires_at;
    private OffsetDateTime created_at;
    private OffsetDateTime updated_at;
}
