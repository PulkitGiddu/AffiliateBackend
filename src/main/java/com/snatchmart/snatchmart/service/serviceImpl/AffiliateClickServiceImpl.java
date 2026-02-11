package com.snatchmart.snatchmart.service.serviceImpl;

import com.snatchmart.snatchmart.DTO.AffiliateClickRequest;
import com.snatchmart.snatchmart.DTO.AffiliateClickResponse;
import com.snatchmart.snatchmart.entity.AffiliateClick;
import com.snatchmart.snatchmart.entity.Product;
import com.snatchmart.snatchmart.entity.UserLogin;
import com.snatchmart.snatchmart.repository.AffiliateClickRepository;
import com.snatchmart.snatchmart.repository.ProductRepository;
import com.snatchmart.snatchmart.repository.UserRepository;
import com.snatchmart.snatchmart.service.AffiliateClickService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@Transactional
public class AffiliateClickServiceImpl implements AffiliateClickService {
    private final AffiliateClickRepository clickRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    public AffiliateClickServiceImpl(
            AffiliateClickRepository clickRepository,
            UserRepository userRepository,
            ProductRepository productRepository
    ) {
        this.clickRepository = clickRepository;
        this.userRepository = userRepository;
        this.productRepository = productRepository;
    }

    @Override
    public AffiliateClickResponse track(AffiliateClickRequest request) {
        UserLogin user = null;
        if (request.getUserId() != null) {
            user = userRepository.findById(request.getUserId())
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
        }
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        AffiliateClick click = AffiliateClick.builder()
                .user(user)
                .product(product)
                .merchantId(request.getMerchantId())
                .deviceInfo(request.getDeviceInfo())
                .ipAddress(request.getIpAddress())
                .build();

        return toResponse(clickRepository.save(click));
    }

    @Override
    public AffiliateClickResponse getById(UUID id) {
        AffiliateClick click = clickRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Click not found"));
        return toResponse(click);
    }

    private AffiliateClickResponse toResponse(AffiliateClick click) {
        return AffiliateClickResponse.builder()
                .id(click.getId())
                .userId(click.getUser() != null ? click.getUser().getId() : null)
                .productId(click.getProduct().getId())
                .merchantId(click.getMerchantId())
                .clickedAt(click.getClickedAt())
                .deviceInfo(click.getDeviceInfo())
                .ipAddress(click.getIpAddress())
                .build();
    }
}
