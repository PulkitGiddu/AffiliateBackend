package com.snatchmart.snatchmart.controller;

import com.snatchmart.snatchmart.DTO.ApiResponse;
import com.snatchmart.snatchmart.DTO.WishlistRequest;
import com.snatchmart.snatchmart.DTO.WishlistResponse;
import com.snatchmart.snatchmart.service.WishlistService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/wishlist")
public class WishlistController {
    private final WishlistService wishlistService;

    public WishlistController(WishlistService wishlistService) {
        this.wishlistService = wishlistService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<WishlistResponse>> add(@RequestBody WishlistRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Wishlist updated", wishlistService.add(request)));
    }

    @DeleteMapping
    public ResponseEntity<ApiResponse<Void>> remove(
            @RequestParam UUID userId,
            @RequestParam UUID productId
    ) {
        wishlistService.remove(userId, productId);
        return ResponseEntity.ok(ApiResponse.ok("Wishlist item removed", null));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<WishlistResponse>>> getByUser(@RequestParam UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Wishlist fetched", wishlistService.getByUser(userId)));
    }
}
