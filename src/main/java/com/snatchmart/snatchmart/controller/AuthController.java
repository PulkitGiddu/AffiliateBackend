package com.snatchmart.snatchmart.controller;

import com.snatchmart.snatchmart.DTO.ApiResponse;
import com.snatchmart.snatchmart.DTO.AuthRequest;
import com.snatchmart.snatchmart.DTO.AuthResponse;
import com.snatchmart.snatchmart.DTO.RegisterRequest;
import com.snatchmart.snatchmart.service.AuthService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Registration successful", authService.register(request)));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody AuthRequest request) {
        log.info("BACKEND received POST /api/v1/auth/login: email={}, password present={}", request.getEmail(), request.getPassword() != null);
        AuthResponse response = authService.login(request);
        log.info("BACKEND auth/login success: userId={}", response.getUserId());
        return ResponseEntity.ok(ApiResponse.ok("Login successful", response));
    }
}
