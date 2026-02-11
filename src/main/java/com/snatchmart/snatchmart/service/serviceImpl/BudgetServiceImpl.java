package com.snatchmart.snatchmart.service.serviceImpl;

import com.snatchmart.snatchmart.DTO.BudgetRequest;
import com.snatchmart.snatchmart.DTO.BudgetResponse;
import com.snatchmart.snatchmart.entity.UserBudget;
import com.snatchmart.snatchmart.entity.UserLogin;
import com.snatchmart.snatchmart.repository.UserBudgetRepository;
import com.snatchmart.snatchmart.repository.UserRepository;
import com.snatchmart.snatchmart.service.BudgetService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class BudgetServiceImpl implements BudgetService {
    private final UserBudgetRepository budgetRepository;
    private final UserRepository userRepository;

    public BudgetServiceImpl(UserBudgetRepository budgetRepository, UserRepository userRepository) {
        this.budgetRepository = budgetRepository;
        this.userRepository = userRepository;
    }

    @Override
    public BudgetResponse create(BudgetRequest request) {
        UserLogin user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        UserBudget budget = UserBudget.builder()
                .user(user)
                .productName(request.getProductName())
                .targetPrice(request.getTargetPrice())
                .currentPrice(request.getCurrentPrice())
                .alertEnabled(request.getAlertEnabled() != null ? request.getAlertEnabled() : true)
                .build();
        return toResponse(budgetRepository.save(budget));
    }

    @Override
    public BudgetResponse update(UUID id, BudgetRequest request) {
        UserBudget budget = budgetRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Budget not found"));
        if (request.getProductName() != null) {
            budget.setProductName(request.getProductName());
        }
        if (request.getTargetPrice() != null) {
            budget.setTargetPrice(request.getTargetPrice());
        }
        if (request.getCurrentPrice() != null) {
            budget.setCurrentPrice(request.getCurrentPrice());
        }
        if (request.getAlertEnabled() != null) {
            budget.setAlertEnabled(request.getAlertEnabled());
        }
        return toResponse(budgetRepository.save(budget));
    }

    @Override
    public List<BudgetResponse> getByUser(UUID userId) {
        return budgetRepository.findByUser_Id(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public void delete(UUID id) {
        budgetRepository.deleteById(id);
    }

    private BudgetResponse toResponse(UserBudget budget) {
        return BudgetResponse.builder()
                .id(budget.getId())
                .userId(budget.getUser().getId())
                .productName(budget.getProductName())
                .targetPrice(budget.getTargetPrice())
                .currentPrice(budget.getCurrentPrice())
                .alertEnabled(budget.getAlertEnabled())
                .createdAt(budget.getCreatedAt())
                .build();
    }
}
