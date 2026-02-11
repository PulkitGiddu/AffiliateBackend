package com.snatchmart.snatchmart.repository;

import com.snatchmart.snatchmart.entity.UserWishlist;
import com.snatchmart.snatchmart.entity.UserWishlistId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserWishlistRepository extends JpaRepository<UserWishlist, UserWishlistId> {
    List<UserWishlist> findByUserId(UUID userId);
}
