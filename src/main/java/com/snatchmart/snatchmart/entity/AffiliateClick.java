package com.snatchmart.snatchmart.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.UuidGenerator;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "affiliate_clicks")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AffiliateClick {
    @Id
    @UuidGenerator
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private UserLogin user;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "merchant_id")
    private UUID merchantId;

    @Column(name = "clicked_at")
    private LocalDateTime clickedAt;

    @Column(name = "device_info")
    private String deviceInfo;

    @Column(name = "ip_address", length = 50)
    private String ipAddress;

    @PrePersist
    public void prePersist() {
        if (this.clickedAt == null) {
            this.clickedAt = LocalDateTime.now();
        }
    }
}
