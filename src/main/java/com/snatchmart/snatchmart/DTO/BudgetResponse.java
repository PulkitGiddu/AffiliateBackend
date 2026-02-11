package com.snatchmart.snatchmart.DTO;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class BudgetResponse {
    private UUID id;
    private UUID userId;
    private String productName;
    private BigDecimal targetPrice;
    private BigDecimal currentPrice;
    private Boolean alertEnabled;
    private LocalDateTime createdAt;
}
