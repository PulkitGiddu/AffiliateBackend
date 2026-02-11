package com.snatchmart.snatchmart.service;

import com.snatchmart.snatchmart.DTO.CouponRequest;
import com.snatchmart.snatchmart.DTO.CouponResponse;

import java.util.List;
import java.util.UUID;

public interface CouponService {
    List<CouponResponse> getAll();
    CouponResponse getById(UUID id);
    CouponResponse create(CouponRequest request);
    CouponResponse update(UUID id, CouponRequest request);
    void delete(UUID id);
}
