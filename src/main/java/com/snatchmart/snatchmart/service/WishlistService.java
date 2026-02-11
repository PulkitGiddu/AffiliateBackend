package com.snatchmart.snatchmart.service;

import com.snatchmart.snatchmart.DTO.WishlistRequest;
import com.snatchmart.snatchmart.DTO.WishlistResponse;

import java.util.List;
import java.util.UUID;

public interface WishlistService {
    WishlistResponse add(WishlistRequest request);
    void remove(UUID userId, UUID productId);
    List<WishlistResponse> getByUser(UUID userId);
}
