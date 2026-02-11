package com.snatchmart.snatchmart.DTO;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class PriceHistoryResponse {
    private UUID id;
    private UUID productId;
    private BigDecimal price;
    private LocalDateTime recordedAt;
}
