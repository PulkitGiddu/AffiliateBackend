package com.snatchmart.snatchmart.controller;

import com.snatchmart.snatchmart.DTO.UserDTO;
import com.snatchmart.snatchmart.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.UUID;

/**
 * Handles user profile management (CRUD).
 *
 * Auth (register / login) is handled by {@link AuthController} at /api/v1/auth.
 * The old POST /api/v1/login endpoint has been removed — use POST /api/v1/auth/login.
 */
@RestController
@RequestMapping("/api/v1")
@Tag(name = "User Management", description = "APIs for user profile, referral system. Use /api/v1/auth for register & login.")
public class UserSignUpController {

    private static final Logger log = LoggerFactory.getLogger(UserSignUpController.class);

    @Autowired
    private UserService userService;

    // ─── Registration ─────────────────────────────────────────────────────────

    /**
     * Register a new user (legacy endpoint – delegates to UserService).
     * Prefer POST /api/v1/auth/register which additionally returns a JWT.
     */
    @PostMapping("/users")
    public ResponseEntity<UserDTO> createUser(@RequestBody UserDTO userDTO) {
        log.info("BACKEND received POST /api/v1/users: email_id={}, username={}", userDTO.getEmail_id(), userDTO.getUsername());
        UserDTO createdUser = userService.createUser(userDTO);
        log.info("BACKEND createUser success: id={}", createdUser.getId());
        return new ResponseEntity<>(createdUser, HttpStatus.CREATED);
    }

    // ─── User profile CRUD ────────────────────────────────────────────────────

    @PutMapping("/{id}")
    @Operation(summary = "Update user information", description = "Update user profile details")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User updated successfully"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "400", description = "Invalid input")
    })
    public ResponseEntity<UserDTO> updateUser(@PathVariable UUID id, @RequestBody UserDTO userDTO) {
        UserDTO updatedUser = userService.updateUser(id, userDTO);
        return new ResponseEntity<>(updatedUser, HttpStatus.OK);
    }

    @GetMapping("/users/{id}")
    @Operation(summary = "Get user by ID", description = "Retrieve user information by their unique ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User found"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<UserDTO> getUserById(@PathVariable UUID id) {
        UserDTO user = userService.getUserById(id);
        return new ResponseEntity<>(user, HttpStatus.OK);
    }

    // ─── Referral system ──────────────────────────────────────────────────────

    @GetMapping("/referral/{referralCode}")
    @Operation(summary = "Get user by referral code")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User found"),
            @ApiResponse(responseCode = "404", description = "Referral code not found")
    })
    public ResponseEntity<UserDTO> getUserByReferralCode(@PathVariable String referralCode) {
        UserDTO user = userService.getUserByReferralCode(referralCode);
        return new ResponseEntity<>(user, HttpStatus.OK);
    }

    @GetMapping("/{id}/referrals")
    @Operation(summary = "Get users referred by a specific user")
    @ApiResponse(responseCode = "200", description = "List of referred users")
    public ResponseEntity<List<UserDTO>> getUsersReferredBy(@PathVariable UUID id) {
        List<UserDTO> referredUsers = userService.getUsersReferredBy(id);
        return new ResponseEntity<>(referredUsers, HttpStatus.OK);
    }

    @GetMapping("/{id}/referral-count")
    @Operation(summary = "Get total referral count")
    @ApiResponse(responseCode = "200", description = "Total referral count")
    public ResponseEntity<Long> getReferralCount(@PathVariable UUID id) {
        Long count = userService.getReferralCount(id);
        return new ResponseEntity<>(count, HttpStatus.OK);
    }

    @GetMapping("/{id}/active-referral-count")
    @Operation(summary = "Get active referral count")
    @ApiResponse(responseCode = "200", description = "Active referral count")
    public ResponseEntity<Long> getActiveReferralCount(@PathVariable UUID id) {
        Long count = userService.getActiveReferralCount(id);
        return new ResponseEntity<>(count, HttpStatus.OK);
    }
}