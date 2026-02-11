package com.snatchmart.snatchmart.repository;

import com.snatchmart.snatchmart.entity.UserBudget;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserBudgetRepository extends JpaRepository<UserBudget, UUID> {
    List<UserBudget> findByUser_Id(UUID userId);
}
