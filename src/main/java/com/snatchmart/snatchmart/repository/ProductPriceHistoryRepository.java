package com.snatchmart.snatchmart.repository;

import com.snatchmart.snatchmart.entity.ProductPriceHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductPriceHistoryRepository extends JpaRepository<ProductPriceHistory, UUID> {
    List<ProductPriceHistory> findByProduct_IdOrderByRecordedAtDesc(UUID productId);
}
