package com.snatchmart.snatchmart.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.UuidGenerator;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "user_budgets")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserBudget {
    @Id
    @UuidGenerator
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserLogin user;

    @Column(name = "product_name")
    private String productName;

    @Column(name = "target_price")
    private BigDecimal targetPrice;

    @Column(name = "current_price")
    private BigDecimal currentPrice;

    @Column(name = "alert_enabled")
    private Boolean alertEnabled = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
        if (this.alertEnabled == null) {
            this.alertEnabled = true;
        }
    }
}
