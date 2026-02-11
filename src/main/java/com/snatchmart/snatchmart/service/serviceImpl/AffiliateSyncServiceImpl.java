package com.snatchmart.snatchmart.service.serviceImpl;

import com.snatchmart.snatchmart.entity.Product;
import com.snatchmart.snatchmart.integration.AffiliateClient;
import com.snatchmart.snatchmart.integration.AffiliateDeal;
import com.snatchmart.snatchmart.repository.ProductRepository;
import com.snatchmart.snatchmart.service.AffiliateSyncService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;

@Service
@Transactional
public class AffiliateSyncServiceImpl implements AffiliateSyncService {
    private static final Logger log = LoggerFactory.getLogger(AffiliateSyncServiceImpl.class);

    private final List<AffiliateClient> affiliateClients;
    private final ProductRepository productRepository;

    public AffiliateSyncServiceImpl(List<AffiliateClient> affiliateClients, ProductRepository productRepository) {
        this.affiliateClients = affiliateClients;
        this.productRepository = productRepository;
    }

    @Override
    public void syncDeals() {
        for (AffiliateClient client : affiliateClients) {
            List<AffiliateDeal> deals = client.fetchLatestDeals();
            for (AffiliateDeal deal : deals) {
                productRepository.findByProductUniqueId(deal.getProductUniqueId())
                        .ifPresent(existing -> updateProductPricing(existing, deal));
            }
            log.info("Synced {} deals from {}", deals.size(), client.provider());
        }
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
        product.setOriginalPrice(deal.getOriginalPrice());
        product.setSalePrice(deal.getSalePrice());
        product.setAffiliateUrl(deal.getAffiliateUrl());
        product.setImageUrl(deal.getImageUrl());
        productRepository.save(product);
    }
}
