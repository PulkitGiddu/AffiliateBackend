package com.snatchmart.snatchmart.controller;

import com.snatchmart.snatchmart.DTO.ApiResponse;
import com.snatchmart.snatchmart.DTO.PageResponse;
import com.snatchmart.snatchmart.DTO.PriceHistoryResponse;
import com.snatchmart.snatchmart.DTO.ProductRequest;
import com.snatchmart.snatchmart.DTO.ProductResponse;
import com.snatchmart.snatchmart.service.ProductService;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/products")
public class ProductController {
    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<ProductResponse>>> search(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) UUID categoryId,
            @RequestParam(required = false) UUID merchantId,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) Boolean active,
            Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.ok("Products fetched",
                productService.search(keyword, categoryId, merchantId, minPrice, maxPrice, active, pageable)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ProductResponse>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Product fetched", productService.getById(id)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ProductResponse>> create(@RequestBody ProductRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Product created", productService.create(request)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ProductResponse>> update(
            @PathVariable UUID id,
            @RequestBody ProductRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.ok("Product updated", productService.update(id, request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        productService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Product deleted", null));
    }

    @GetMapping("/{id}/price-history")
    public ResponseEntity<ApiResponse<List<PriceHistoryResponse>>> priceHistory(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Price history fetched", productService.getPriceHistory(id)));
    }
}
