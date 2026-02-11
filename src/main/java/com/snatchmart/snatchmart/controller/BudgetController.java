package com.snatchmart.snatchmart.controller;

import com.snatchmart.snatchmart.DTO.ApiResponse;
import com.snatchmart.snatchmart.DTO.BudgetRequest;
import com.snatchmart.snatchmart.DTO.BudgetResponse;
import com.snatchmart.snatchmart.service.BudgetService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/budgets")
public class BudgetController {
    private final BudgetService budgetService;

    public BudgetController(BudgetService budgetService) {
        this.budgetService = budgetService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<BudgetResponse>> create(@RequestBody BudgetRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Budget created", budgetService.create(request)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<BudgetResponse>> update(
            @PathVariable UUID id,
            @RequestBody BudgetRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.ok("Budget updated", budgetService.update(id, request)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<BudgetResponse>>> getByUser(@RequestParam UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Budgets fetched", budgetService.getByUser(userId)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        budgetService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Budget deleted", null));
    }
}
