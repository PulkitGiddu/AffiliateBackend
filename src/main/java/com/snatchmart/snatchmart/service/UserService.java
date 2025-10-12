package com.snatchmart.snatchmart.service;

import com.snatchmart.snatchmart.DTO.UserDTO;
import java.util.List;
import java.util.UUID;

public interface UserService {

    /**
     * Create a new user with auto-generated referral code
     */
    UserDTO createUser(UserDTO userDTO);

    /**
     * Update an existing user
     */
    UserDTO updateUser(UUID id, UserDTO userDTO);

    /**
     * Get user by ID
     */
    UserDTO getUserById(UUID id);

    /**
     * Get all users
     */
    List<UserDTO> getAllUsers();

    /**
     * User login with email and password
     */
    UserDTO login(UserDTO userDTO);

    /**
     * Get user by referral code
     */
    UserDTO getUserByReferralCode(String referralCode);

    /**
     * Get all users referred by a specific user
     */
    List<UserDTO> getUsersReferredBy(UUID userId);

    /**
     * Get referral count for a user
     */
    Long getReferralCount(UUID userId);

    /**
     * Get active referral count for a user
     */
    Long getActiveReferralCount(UUID userId);
}