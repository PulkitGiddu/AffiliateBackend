package com.snatchmart.snatchmart.service;

import com.snatchmart.snatchmart.DTO.BudgetRequest;
import com.snatchmart.snatchmart.DTO.BudgetResponse;

import java.util.List;
import java.util.UUID;

public interface BudgetService {
    BudgetResponse create(BudgetRequest request);
    BudgetResponse update(UUID id, BudgetRequest request);
    List<BudgetResponse> getByUser(UUID userId);
    void delete(UUID id);
}
