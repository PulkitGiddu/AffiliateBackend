package com.snatchmart.snatchmart.service.serviceImpl;

import com.snatchmart.snatchmart.DTO.PageResponse;
import com.snatchmart.snatchmart.DTO.PriceHistoryResponse;
import com.snatchmart.snatchmart.DTO.ProductRequest;
import com.snatchmart.snatchmart.DTO.ProductResponse;
import com.snatchmart.snatchmart.entity.Category;
import com.snatchmart.snatchmart.entity.Merchant;
import com.snatchmart.snatchmart.entity.Product;
import com.snatchmart.snatchmart.entity.ProductPriceHistory;
import com.snatchmart.snatchmart.repository.CategoryRepository;
import com.snatchmart.snatchmart.repository.MerchantRepository;
import com.snatchmart.snatchmart.repository.ProductPriceHistoryRepository;
import com.snatchmart.snatchmart.repository.ProductRepository;
import com.snatchmart.snatchmart.service.ProductService;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class ProductServiceImpl implements ProductService {
    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final MerchantRepository merchantRepository;
    private final ProductPriceHistoryRepository priceHistoryRepository;

    public ProductServiceImpl(
            ProductRepository productRepository,
            CategoryRepository categoryRepository,
            MerchantRepository merchantRepository,
            ProductPriceHistoryRepository priceHistoryRepository
    ) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
        this.merchantRepository = merchantRepository;
        this.priceHistoryRepository = priceHistoryRepository;
    }

    @Override
    @Cacheable(cacheNames = "product_search", key = "{#keyword, #categoryId, #merchantId, #minPrice, #maxPrice, #active, #pageable.pageNumber, #pageable.pageSize}")
    public PageResponse<ProductResponse> search(
            String keyword,
            UUID categoryId,
            UUID merchantId,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Boolean active,
            Pageable pageable
    ) {
        Specification<Product> spec = Specification.where(null);
        if (keyword != null && !keyword.isBlank()) {
            spec = spec.and((root, query, cb) ->
                    cb.like(cb.lower(root.get("productName")), "%" + keyword.toLowerCase() + "%"));
        }
        if (categoryId != null) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("category").get("id"), categoryId));
        }
        if (merchantId != null) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("merchant").get("id"), merchantId));
        }
        if (minPrice != null) {
            spec = spec.and((root, query, cb) -> cb.greaterThanOrEqualTo(root.get("salePrice"), minPrice));
        }
        if (maxPrice != null) {
            spec = spec.and((root, query, cb) -> cb.lessThanOrEqualTo(root.get("salePrice"), maxPrice));
        }
        if (active != null) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("isActive"), active));
        }

        Page<Product> page = productRepository.findAll(spec, pageable);
        List<ProductResponse> items = page.getContent().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());

        return PageResponse.<ProductResponse>builder()
                .items(items)
                .page(page.getNumber())
                .size(page.getSize())
                .totalElements(page.getTotalElements())
                .totalPages(page.getTotalPages())
                .hasNext(page.hasNext())
                .build();
    }

    @Override
    public ProductResponse getById(UUID id) {
        return toResponse(getProduct(id));
    }

    @Override
    public ProductResponse create(ProductRequest request) {
        Merchant merchant = merchantRepository.findById(request.getMerchantId())
                .orElseThrow(() -> new IllegalArgumentException("Merchant not found"));
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));

        Product product = Product.builder()
                .productName(request.getProductName())
                .description(request.getDescription())
                .productUniqueId(request.getProductUniqueId())
                .originalPrice(request.getOriginalPrice())
                .salePrice(request.getSalePrice())
                .reviewScore(request.getReviewScore())
                .reviewCount(request.getReviewCount() != null ? request.getReviewCount() : 0)
                .affiliateUrl(request.getAffiliateUrl())
                .imageUrl(request.getImageUrl())
                .merchant(merchant)
                .category(category)
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .dealsExpiresAt(request.getDealsExpiresAt())
                .build();

        Product saved = productRepository.save(product);
        recordPriceHistory(saved);
        return toResponse(saved);
    }

    @Override
    public ProductResponse update(UUID id, ProductRequest request) {
        Product product = getProduct(id);
        if (request.getProductName() != null) {
            product.setProductName(request.getProductName());
        }
        if (request.getDescription() != null) {
            product.setDescription(request.getDescription());
        }
        if (request.getProductUniqueId() != null) {
            product.setProductUniqueId(request.getProductUniqueId());
        }
        if (request.getOriginalPrice() != null) {
            product.setOriginalPrice(request.getOriginalPrice());
        }
        if (request.getSalePrice() != null) {
            product.setSalePrice(request.getSalePrice());
            recordPriceHistory(product);
        }
        if (request.getReviewScore() != null) {
            product.setReviewScore(request.getReviewScore());
        }
        if (request.getReviewCount() != null) {
            product.setReviewCount(request.getReviewCount());
        }
        if (request.getAffiliateUrl() != null) {
            product.setAffiliateUrl(request.getAffiliateUrl());
        }
        if (request.getImageUrl() != null) {
            product.setImageUrl(request.getImageUrl());
        }
        if (request.getMerchantId() != null) {
            Merchant merchant = merchantRepository.findById(request.getMerchantId())
                    .orElseThrow(() -> new IllegalArgumentException("Merchant not found"));
            product.setMerchant(merchant);
        }
        if (request.getCategoryId() != null) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new IllegalArgumentException("Category not found"));
            product.setCategory(category);
        }
        if (request.getIsActive() != null) {
            product.setIsActive(request.getIsActive());
        }
        if (request.getDealsExpiresAt() != null) {
            product.setDealsExpiresAt(request.getDealsExpiresAt());
        }

        return toResponse(productRepository.save(product));
    }

    @Override
    public void delete(UUID id) {
        productRepository.deleteById(id);
    }

    @Override
    public List<PriceHistoryResponse> getPriceHistory(UUID productId) {
        return priceHistoryRepository.findByProduct_IdOrderByRecordedAtDesc(productId).stream()
                .map(history -> PriceHistoryResponse.builder()
                        .id(history.getId())
                        .productId(history.getProduct().getId())
                        .price(history.getPrice())
                        .recordedAt(history.getRecordedAt())
                        .build())
                .collect(Collectors.toList());
    }

    private Product getProduct(UUID id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));
    }

    private void recordPriceHistory(Product product) {
        ProductPriceHistory history = ProductPriceHistory.builder()
                .product(product)
                .price(product.getSalePrice())
                .build();
        priceHistoryRepository.save(history);
    }

    private ProductResponse toResponse(Product product) {
        return ProductResponse.builder()
                .id(product.getId())
                .productName(product.getProductName())
                .description(product.getDescription())
                .productUniqueId(product.getProductUniqueId())
                .originalPrice(product.getOriginalPrice())
                .salePrice(product.getSalePrice())
                .reviewScore(product.getReviewScore())
                .reviewCount(product.getReviewCount())
                .affiliateUrl(product.getAffiliateUrl())
                .imageUrl(product.getImageUrl())
                .merchantId(product.getMerchant().getId())
                .categoryId(product.getCategory().getId())
                .isActive(product.getIsActive())
                .dealsExpiresAt(product.getDealsExpiresAt())
                .build();
    }
}
