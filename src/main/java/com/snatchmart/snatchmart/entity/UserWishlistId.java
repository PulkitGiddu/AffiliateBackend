package com.snatchmart.snatchmart.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserWishlistId implements Serializable {
    private UUID userId;
    private UUID productId;
}
