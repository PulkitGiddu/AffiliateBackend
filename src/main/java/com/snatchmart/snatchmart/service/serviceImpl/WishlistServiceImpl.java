package com.snatchmart.snatchmart.service.serviceImpl;

import com.snatchmart.snatchmart.DTO.WishlistRequest;
import com.snatchmart.snatchmart.DTO.WishlistResponse;
import com.snatchmart.snatchmart.entity.UserWishlist;
import com.snatchmart.snatchmart.entity.UserWishlistId;
import com.snatchmart.snatchmart.repository.UserWishlistRepository;
import com.snatchmart.snatchmart.service.WishlistService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class WishlistServiceImpl implements WishlistService {
    private final UserWishlistRepository wishlistRepository;

    public WishlistServiceImpl(UserWishlistRepository wishlistRepository) {
        this.wishlistRepository = wishlistRepository;
    }

    @Override
    public WishlistResponse add(WishlistRequest request) {
        UserWishlist wishlist = new UserWishlist();
        wishlist.setUserId(request.getUserId());
        wishlist.setProductId(request.getProductId());
        return toResponse(wishlistRepository.save(wishlist));
    }

    @Override
    public void remove(UUID userId, UUID productId) {
        wishlistRepository.deleteById(new UserWishlistId(userId, productId));
    }

    @Override
    public List<WishlistResponse> getByUser(UUID userId) {
        return wishlistRepository.findByUserId(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    private WishlistResponse toResponse(UserWishlist wishlist) {
        return WishlistResponse.builder()
                .userId(wishlist.getUserId())
                .productId(wishlist.getProductId())
                .createdAt(wishlist.getCreatedAt())
                .build();
    }
}
