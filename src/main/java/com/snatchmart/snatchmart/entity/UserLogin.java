package com.snatchmart.snatchmart.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.UuidGenerator;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "user_login", indexes = {
        @Index(name = "idx_user_login_email", columnList = "email_id"),
        @Index(name = "idx_user_login_username", columnList = "username"),
        @Index(name = "idx_user_login_referral_code", columnList = "referral_code"),
        @Index(name = "idx_user_login_referred_by_id", columnList = "referred_by_id"),
        @Index(name = "idx_user_login_is_active", columnList = "is_active")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserLogin {

    @Id
    @UuidGenerator
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "email_id", unique = true, nullable = false, length = 255)
    private String emailId;

    @Column(name = "username", unique = true, nullable = false, length = 255)
    private String username;

    @Column(name = "first_name", length = 255)
    private String firstName;

    @Column(name = "last_name", length = 255)
    private String lastName;

    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "referral_code", unique = true, nullable = false, length = 50)
    private String referralCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "referred_by_id", referencedColumnName = "id", nullable = true)
    private UserLogin referredBy;

    @Column(name = "profile_picture_url", length = 2048)
    private String profilePictureUrl;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    /**
     * Lifecycle method to set createdAt and updatedAt before persist
     */
    @PrePersist
    public void prePersist() {
        OffsetDateTime now = OffsetDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
        if (this.isActive == null) {
            this.isActive = true;
        }
    }

    /**
     * Lifecycle method to update updatedAt before update
     */
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = OffsetDateTime.now();
    }
}