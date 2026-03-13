package com.snatchmart.snatchmart.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Public health check. Use to verify the server is running and reachable
 * (e.g. from phone: http://YOUR_PC_IP:8081/health).
 */
@RestController
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "snatchmart"
        ));
    }
}
