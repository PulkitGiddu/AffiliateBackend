package com.snatchmart.snatchmart.entity;

import jakarta.persistence.*;
import java.util.UUID;
import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(generator = "UUID")
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "product_name", nullable = false)
    private String productName;

    @Column(name = "description")
    private String description;

    @Column(name = "product_unique_id", unique = true, nullable = false)
    private String productUniqueId;

    @Column(name = "original_price")
    private BigDecimal originalPrice;

    @Column(name = "sale_price", nullable = false)
    private BigDecimal salePrice;

    @Column(name = "review_score")
    private Double reviewScore;

    @Column(name = "review_count")
    private Integer reviewCount = 0;

    @Column(name = "affiliate_url", nullable = false)
    private String affiliateUrl;

    @Column(name = "image_url")
    private String imageUrl;

    @ManyToOne(optional = false)
    @JoinColumn(name = "merchant_id", referencedColumnName = "id")
    private Merchant merchant;

    @ManyToOne(optional = false)
    @JoinColumn(name = "category_id", referencedColumnName = "id")
    private Category category;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "deals_expires_at")
    private OffsetDateTime dealsExpiresAt;

    @Column(name = "created_at")
    private OffsetDateTime createdAt;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    // Getters and setters
    // ...existing code...
}

