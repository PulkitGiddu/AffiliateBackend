package com.snatchmart.snatchmart.controller;

import com.snatchmart.snatchmart.DTO.AffiliateClickRequest;
import com.snatchmart.snatchmart.DTO.AffiliateClickResponse;
import com.snatchmart.snatchmart.DTO.ApiResponse;
import com.snatchmart.snatchmart.service.AffiliateClickService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/affiliate-clicks")
public class AffiliateClickController {
    private final AffiliateClickService affiliateClickService;

    public AffiliateClickController(AffiliateClickService affiliateClickService) {
        this.affiliateClickService = affiliateClickService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<AffiliateClickResponse>> track(@RequestBody AffiliateClickRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Click tracked", affiliateClickService.track(request)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<AffiliateClickResponse>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Click fetched", affiliateClickService.getById(id)));
    }
}
