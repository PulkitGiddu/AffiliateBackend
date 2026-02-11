package com.snatchmart.snatchmart.DTO;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class WishlistResponse {
    private UUID userId;
    private UUID productId;
    private LocalDateTime createdAt;
}
