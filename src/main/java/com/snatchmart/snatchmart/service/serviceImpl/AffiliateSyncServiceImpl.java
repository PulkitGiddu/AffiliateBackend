package com.snatchmart.snatchmart.service.serviceImpl;

import com.snatchmart.snatchmart.entity.Category;
import com.snatchmart.snatchmart.entity.Merchant;
import com.snatchmart.snatchmart.entity.Product;
import com.snatchmart.snatchmart.integration.AffiliateClient;
import com.snatchmart.snatchmart.integration.AffiliateDeal;
import com.snatchmart.snatchmart.repository.CategoryRepository;
import com.snatchmart.snatchmart.repository.MerchantRepository;
import com.snatchmart.snatchmart.repository.ProductRepository;
import com.snatchmart.snatchmart.service.AffiliateSyncService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

@Service
@Transactional
public class AffiliateSyncServiceImpl implements AffiliateSyncService {
    private static final Logger log = LoggerFactory.getLogger(AffiliateSyncServiceImpl.class);

    private final List<AffiliateClient> affiliateClients;
    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final MerchantRepository merchantRepository;

    public AffiliateSyncServiceImpl(
            List<AffiliateClient> affiliateClients,
            ProductRepository productRepository,
            CategoryRepository categoryRepository,
            MerchantRepository merchantRepository
    ) {
        this.affiliateClients = affiliateClients;
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
        this.merchantRepository = merchantRepository;
    }

    @Override
    public void syncDeals() {
        for (AffiliateClient client : affiliateClients) {
            List<AffiliateDeal> deals = client.fetchLatestDeals();
            int skipped = 0;
            for (AffiliateDeal deal : deals) {
                // Skip deals with no valid price — would violate chk_price_positive constraint
                if (deal.getSalePrice() == null || deal.getSalePrice().compareTo(java.math.BigDecimal.ONE) < 0) {
                    skipped++;
                    continue;
                }
                productRepository.findByProductUniqueId(deal.getProductUniqueId())
                        .ifPresentOrElse(
                                existing -> updateProductPricing(existing, deal),
                                () -> createProductFromDeal(deal)
                        );
            }
            log.info("Synced {} deals from {} ({} skipped — no valid price)", deals.size() - skipped, client.provider(), skipped);
        }
    }

    private void createProductFromDeal(AffiliateDeal deal) {
        String merchantName = deal.getMerchantName() != null && !deal.getMerchantName().isBlank()
                ? deal.getMerchantName() : "Affiliate";
        String categorySlug = deal.getCategorySlug() != null && !deal.getCategorySlug().isBlank()
                ? deal.getCategorySlug() : "deals";

        Merchant merchant = merchantRepository.findByNameIgnoreCase(merchantName)
                .orElseGet(() -> {
                    Merchant m = Merchant.builder()
                            .name(merchantName)
                            .build();
                    return merchantRepository.save(m);
                });

        Category category = categoryRepository.findBySlug(categorySlug)
                .orElseGet(() -> {
                    Category c = Category.builder()
                            .name(categorySlug.replace("-", " "))
                            .slug(categorySlug)
                            .build();
                    return categoryRepository.save(c);
                });

        BigDecimal salePrice = deal.getSalePrice() != null ? deal.getSalePrice() : BigDecimal.ZERO;
        BigDecimal originalPrice = deal.getOriginalPrice() != null ? deal.getOriginalPrice() : salePrice;

        Product product = Product.builder()
                .productName(deal.getProductName() != null ? deal.getProductName() : "Deal")
                .description(deal.getDescription())
                .productUniqueId(deal.getProductUniqueId())
                .originalPrice(originalPrice)
                .salePrice(salePrice)
                .affiliateUrl(deal.getAffiliateUrl())
                .imageUrl(deal.getImageUrl())
                .merchant(merchant)
                .category(category)
                .isActive(true)
                .build();
        productRepository.save(product);
    }

    @Override
    public void cleanupExpiredDeals() {
        List<Product> expired = productRepository.findAll((root, query, cb) ->
                cb.lessThan(root.get("dealsExpiresAt"), OffsetDateTime.now()));
        expired.forEach(product -> product.setIsActive(false));
        productRepository.saveAll(expired);
        log.info("Deactivated {} expired deals", expired.size());
    }

    private void updateProductPricing(Product product, AffiliateDeal deal) {
        if (deal.getOriginalPrice() != null) {
            product.setOriginalPrice(deal.getOriginalPrice());
        }
        if (deal.getSalePrice() != null) {
            product.setSalePrice(deal.getSalePrice());
        }
        if (deal.getAffiliateUrl() != null) {
            product.setAffiliateUrl(deal.getAffiliateUrl());
        }
        if (deal.getImageUrl() != null) {
            product.setImageUrl(deal.getImageUrl());
        }
        if (deal.getProductName() != null) {
            product.setProductName(deal.getProductName());
        }
        if (deal.getDescription() != null) {
            product.setDescription(deal.getDescription());
        }
        productRepository.save(product);
    }
}
