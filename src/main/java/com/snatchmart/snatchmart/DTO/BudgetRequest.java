package com.snatchmart.snatchmart.DTO;

import lombok.Data;

import java.math.BigDecimal;
import java.util.UUID;

@Data
public class BudgetRequest {
    private UUID userId;
    private String productName;
    private BigDecimal targetPrice;
    private BigDecimal currentPrice;
    private Boolean alertEnabled;
}
