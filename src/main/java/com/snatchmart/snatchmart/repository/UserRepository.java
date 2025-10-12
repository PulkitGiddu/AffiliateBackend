package com.snatchmart.snatchmart.repository;

import com.snatchmart.snatchmart.entity.UserLogin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<UserLogin, UUID> {

    /**
     * Find user by email
     */
    Optional<UserLogin> findByEmailId(String emailId);

    /**
     * Find user by username
     */
    Optional<UserLogin> findByUsername(String username);

    /**
     * Find user by their unique referral code
     */
    Optional<UserLogin> findByReferralCode(String referralCode);

    /**
     * Check if referral code already exists
     */
    boolean existsByReferralCode(String referralCode);

    /**
     * Find all users referred by a specific user
     * Usage: Get all users that signed up using User A's referral code
     */
    @Query("SELECT u FROM UserLogin u WHERE u.referredBy.id = :referrerId")
    List<UserLogin> findByReferredById(@Param("referrerId") UUID referrerId);

    /**
     * Count total referrals for a user
     */
    @Query("SELECT COUNT(u) FROM UserLogin u WHERE u.referredBy.id = :referrerId")
    Long countReferralsByUserId(@Param("referrerId") UUID referrerId);

    /**
     * Count active referrals for a user
     */
    @Query("SELECT COUNT(u) FROM UserLogin u WHERE u.referredBy.id = :referrerId AND u.isActive = true")
    Long countActiveReferrals(@Param("referrerId") UUID referrerId);

    /**
     * Find users by active status
     */
    List<UserLogin> findByIsActiveTrue();

    /**
     * Find inactive users
     */
    List<UserLogin> findByIsActiveFalse();

    /**
     * Find users referred by someone with active status
     */
    @Query("SELECT u FROM UserLogin u WHERE u.referredBy.id = :referrerId AND u.isActive = :isActive")
    List<UserLogin> findReferralsByUserAndStatus(
            @Param("referrerId") UUID referrerId,
            @Param("isActive") Boolean isActive
    );
}