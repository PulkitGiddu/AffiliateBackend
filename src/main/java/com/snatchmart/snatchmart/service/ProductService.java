package com.snatchmart.snatchmart.service;

import com.snatchmart.snatchmart.DTO.PageResponse;
import com.snatchmart.snatchmart.DTO.PriceHistoryResponse;
import com.snatchmart.snatchmart.DTO.ProductRequest;
import com.snatchmart.snatchmart.DTO.ProductResponse;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public interface ProductService {
    PageResponse<ProductResponse> search(
            String keyword,
            UUID categoryId,
            UUID merchantId,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Boolean active,
            Pageable pageable
    );

    ProductResponse getById(UUID id);

    ProductResponse create(ProductRequest request);

    ProductResponse update(UUID id, ProductRequest request);

    void delete(UUID id);

    List<PriceHistoryResponse> getPriceHistory(UUID productId);
}
