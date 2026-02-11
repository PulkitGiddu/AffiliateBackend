package com.snatchmart.snatchmart.service.serviceImpl;

import com.snatchmart.snatchmart.DTO.CouponRequest;
import com.snatchmart.snatchmart.DTO.CouponResponse;
import com.snatchmart.snatchmart.entity.Coupon;
import com.snatchmart.snatchmart.entity.Merchant;
import com.snatchmart.snatchmart.repository.CouponRepository;
import com.snatchmart.snatchmart.repository.MerchantRepository;
import com.snatchmart.snatchmart.service.CouponService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class CouponServiceImpl implements CouponService {
    private final CouponRepository couponRepository;
    private final MerchantRepository merchantRepository;

    public CouponServiceImpl(CouponRepository couponRepository, MerchantRepository merchantRepository) {
        this.couponRepository = couponRepository;
        this.merchantRepository = merchantRepository;
    }

    @Override
    public List<CouponResponse> getAll() {
        return couponRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public CouponResponse getById(UUID id) {
        return toResponse(getCoupon(id));
    }

    @Override
    public CouponResponse create(CouponRequest request) {
        Merchant merchant = null;
        if (request.getMerchantId() != null) {
            merchant = merchantRepository.findById(request.getMerchantId())
                    .orElseThrow(() -> new IllegalArgumentException("Merchant not found"));
        }

        Coupon coupon = Coupon.builder()
                .code(request.getCode())
                .description(request.getDescription())
                .discountType(request.getDiscountType())
                .discountValue(request.getDiscountValue())
                .expiryAt(request.getExpiryAt())
                .merchant(merchant)
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .build();
        return toResponse(couponRepository.save(coupon));
    }

    @Override
    public CouponResponse update(UUID id, CouponRequest request) {
        Coupon coupon = getCoupon(id);
        if (request.getCode() != null) {
            coupon.setCode(request.getCode());
        }
        if (request.getDescription() != null) {
            coupon.setDescription(request.getDescription());
        }
        if (request.getDiscountType() != null) {
            coupon.setDiscountType(request.getDiscountType());
        }
        if (request.getDiscountValue() != null) {
            coupon.setDiscountValue(request.getDiscountValue());
        }
        if (request.getExpiryAt() != null) {
            coupon.setExpiryAt(request.getExpiryAt());
        }
        if (request.getMerchantId() != null) {
            Merchant merchant = merchantRepository.findById(request.getMerchantId())
                    .orElseThrow(() -> new IllegalArgumentException("Merchant not found"));
            coupon.setMerchant(merchant);
        }
        if (request.getIsActive() != null) {
            coupon.setIsActive(request.getIsActive());
        }
        return toResponse(couponRepository.save(coupon));
    }

    @Override
    public void delete(UUID id) {
        couponRepository.deleteById(id);
    }

    private Coupon getCoupon(UUID id) {
        return couponRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Coupon not found"));
    }

    private CouponResponse toResponse(Coupon coupon) {
        return CouponResponse.builder()
                .id(coupon.getId())
                .code(coupon.getCode())
                .description(coupon.getDescription())
                .discountType(coupon.getDiscountType())
                .discountValue(coupon.getDiscountValue())
                .expiryAt(coupon.getExpiryAt())
                .merchantId(coupon.getMerchant() != null ? coupon.getMerchant().getId() : null)
                .isActive(coupon.getIsActive())
                .build();
    }
}
