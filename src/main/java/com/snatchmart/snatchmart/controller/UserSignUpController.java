package com.snatchmart.snatchmart.controller;

import com.snatchmart.snatchmart.DTO.UserDTO;
import com.snatchmart.snatchmart.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
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

@RestController
@RequestMapping("/api/v1")
@Tag(name = "User Management", description = "APIs for user registration, login, and referral system")
public class UserSignUpController {

    private static final Logger log = LoggerFactory.getLogger(UserSignUpController.class);

    @Autowired
    private UserService userService;

    @PostMapping("/users")
    public ResponseEntity<UserDTO> createUser(@RequestBody UserDTO userDTO) {
        log.info("BACKEND received POST /api/v1/users (register): email_id={}, username={}, first_name={}, last_name={}, password_hash present={}, referred_by_code={}",
                userDTO.getEmail_id(), userDTO.getUsername(), userDTO.getFirst_name(), userDTO.getLast_name(),
                userDTO.getPassword_hash() != null, userDTO.getReferred_by_code());
        UserDTO createdUser = userService.createUser(userDTO);
        log.info("BACKEND createUser success: id={}, email_id={}", createdUser.getId(), createdUser.getEmail_id());
        return new ResponseEntity<>(createdUser, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update user information",
            description = "Update user profile details")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User updated successfully"),
            @ApiResponse(responseCode = "404", description = "User not found"),
            @ApiResponse(responseCode = "400", description = "Invalid input")
    })
    public ResponseEntity<UserDTO> updateUser(@PathVariable UUID id, @RequestBody UserDTO userDTO) {
        UserDTO updatedUser = userService.updateUser(id, userDTO);
        return new ResponseEntity<>(updatedUser, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID",
            description = "Retrieve user information by their unique ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User found"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<UserDTO> getUserById(@PathVariable UUID id) {
        UserDTO user = userService.getUserById(id);
        return new ResponseEntity<>(user, HttpStatus.OK);
    }

    @GetMapping
    @Operation(summary = "Get all users",
            description = "Retrieve all registered users")
    @ApiResponse(responseCode = "200", description = "List of all users")
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        List<UserDTO> users = userService.getAllUsers();
        return new ResponseEntity<>(users, HttpStatus.OK);
    }

    @PostMapping("/login")
    @Operation(summary = "User login",
            description = "Authenticate user with email and password")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Login successful"),
            @ApiResponse(responseCode = "401", description = "Invalid credentials"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<UserDTO> login(@RequestBody UserDTO userDTO) {
        log.info("BACKEND received POST /api/v1/login: email_id={}, password present={}", userDTO.getEmail_id(), userDTO.getPassword_hash() != null);
        UserDTO loggedInUser = userService.login(userDTO);
        log.info("BACKEND login success: id={}", loggedInUser.getId());
        return new ResponseEntity<>(loggedInUser, HttpStatus.OK);
    }

    @GetMapping("/referral/{referralCode}")
    @Operation(summary = "Get user by referral code",
            description = "Find a user using their referral code")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User found"),
            @ApiResponse(responseCode = "404", description = "Referral code not found")
    })
    public ResponseEntity<UserDTO> getUserByReferralCode(@PathVariable String referralCode) {
        UserDTO user = userService.getUserByReferralCode(referralCode);
        return new ResponseEntity<>(user, HttpStatus.OK);
    }

    @GetMapping("/{id}/referrals")
    @Operation(summary = "Get users referred by a specific user",
            description = "Get all users who signed up using this user's referral code")
    @ApiResponse(responseCode = "200", description = "List of referred users")
    public ResponseEntity<List<UserDTO>> getUsersReferredBy(@PathVariable UUID id) {
        List<UserDTO> referredUsers = userService.getUsersReferredBy(id);
        return new ResponseEntity<>(referredUsers, HttpStatus.OK);
    }

    @GetMapping("/{id}/referral-count")
    @Operation(summary = "Get total referral count",
            description = "Get the total number of users referred by this user")
    @ApiResponse(responseCode = "200", description = "Total referral count")
    public ResponseEntity<Long> getReferralCount(@PathVariable UUID id) {
        Long count = userService.getReferralCount(id);
        return new ResponseEntity<>(count, HttpStatus.OK);
    }

    @GetMapping("/{id}/active-referral-count")
    @Operation(summary = "Get active referral count",
            description = "Get the number of active users referred by this user")
    @ApiResponse(responseCode = "200", description = "Active referral count")
    public ResponseEntity<Long> getActiveReferralCount(@PathVariable UUID id) {
        Long count = userService.getActiveReferralCount(id);
        return new ResponseEntity<>(count, HttpStatus.OK);
    }
}