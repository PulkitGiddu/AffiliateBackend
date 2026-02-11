package com.snatchmart.snatchmart.service;

import com.snatchmart.snatchmart.DTO.AuthRequest;
import com.snatchmart.snatchmart.DTO.AuthResponse;
import com.snatchmart.snatchmart.DTO.RegisterRequest;

public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(AuthRequest request);
}
