package com.snatchmart.snatchmart.controller;

import com.snatchmart.snatchmart.DTO.ApiResponse;
import com.snatchmart.snatchmart.DTO.CouponRequest;
import com.snatchmart.snatchmart.DTO.CouponResponse;
import com.snatchmart.snatchmart.service.CouponService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/coupons")
public class CouponController {
    private final CouponService couponService;

    public CouponController(CouponService couponService) {
        this.couponService = couponService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<CouponResponse>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok("Coupons fetched", couponService.getAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CouponResponse>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Coupon fetched", couponService.getById(id)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<CouponResponse>> create(@RequestBody CouponRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Coupon created", couponService.create(request)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<CouponResponse>> update(
            @PathVariable UUID id,
            @RequestBody CouponRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.ok("Coupon updated", couponService.update(id, request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        couponService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Coupon deleted", null));
    }
}
