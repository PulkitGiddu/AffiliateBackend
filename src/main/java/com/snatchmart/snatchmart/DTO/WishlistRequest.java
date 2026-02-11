package com.snatchmart.snatchmart.DTO;

import lombok.Data;

import java.util.UUID;

@Data
public class WishlistRequest {
    private UUID userId;
    private UUID productId;
}
