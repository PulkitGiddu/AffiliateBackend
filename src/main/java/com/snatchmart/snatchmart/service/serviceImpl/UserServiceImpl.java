package com.snatchmart.snatchmart.service.serviceImpl;

import com.snatchmart.snatchmart.DTO.UserDTO;
import com.snatchmart.snatchmart.entity.UserLogin;
import com.snatchmart.snatchmart.exception.DuplicateUserException;
import com.snatchmart.snatchmart.exception.UserNotFoundException;
import com.snatchmart.snatchmart.repository.UserRepository;
import com.snatchmart.snatchmart.service.ReferralCodeGenerator;
import com.snatchmart.snatchmart.service.UserService;
import com.snatchmart.snatchmart.validator.UserSignUpValidation;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class UserServiceImpl implements UserService {

    private static final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ModelMapper modelMapper;

    @Autowired
    private UserSignUpValidation validation;

    @Autowired
    private ReferralCodeGenerator referralCodeGenerator;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Create a new user with auto-generated referral code
     */
    @Override
    public UserDTO createUser(UserDTO userDTO) {
        log.info("UserService.createUser received: email_id={}, username={}", userDTO.getEmail_id(), userDTO.getUsername());
        // Validate signup data
        validation.validateSignUp(userDTO);
        userDTO.setId(null);

        // Fail fast with clear 409 instead of DB constraint violation
        userRepository.findByEmailId(userDTO.getEmail_id().trim())
                .ifPresent(u -> {
                    throw new DuplicateUserException("This email is already registered. Please sign in.");
                });
        userRepository.findByUsername(userDTO.getUsername().trim())
                .ifPresent(u -> {
                    throw new DuplicateUserException("This username is already taken. Please choose another.");
                });

        // Build user entity
        UserLogin user = UserLogin.builder()
                .emailId(userDTO.getEmail_id())
                .username(userDTO.getUsername())
                .firstName(userDTO.getFirst_name())
                .lastName(userDTO.getLast_name())
                .passwordHash(passwordEncoder.encode(userDTO.getPassword_hash()))
                .isActive(userDTO.getIs_active() != null ? userDTO.getIs_active() : true)
                .profilePictureUrl(userDTO.getProfile_picture_url())
                .build();

        // AUTO-GENERATE unique referral code for this user
        String uniqueReferralCode = generateUniqueReferralCode();
        user.setReferralCode(uniqueReferralCode);

        // Handle referred_by logic - look up by referral code provided
        if (userDTO.getReferred_by_code() != null && !userDTO.getReferred_by_code().trim().isEmpty()) {
            Optional<UserLogin> referrer = userRepository.findByReferralCode(userDTO.getReferred_by_code());
            if (referrer.isPresent()) {
                user.setReferredBy(referrer.get());
            } else {
                throw new IllegalArgumentException(
                        "Invalid referral code provided: " + userDTO.getReferred_by_code()
                );
            }
        }
        // Alternative: Use referred_by_id if provided (direct ID reference)
        else if (userDTO.getReferred_by_id() != null) {
            Optional<UserLogin> referrer = userRepository.findById(userDTO.getReferred_by_id());
            if (referrer.isPresent()) {
                user.setReferredBy(referrer.get());
            } else {
                throw new IllegalArgumentException(
                        "Invalid referrer ID: " + userDTO.getReferred_by_id()
                );
            }
        }

        // Timestamps are set automatically by @PrePersist, but explicit for clarity
        OffsetDateTime now = OffsetDateTime.now();
        user.setCreatedAt(now);
        user.setUpdatedAt(now);

        // Save user to database
        log.info("UserService.createUser saving to DB: emailId={}, username={}", user.getEmailId(), user.getUsername());
        user = userRepository.save(user);
        log.info("UserService.createUser saved to DB: id={}, emailId={}", user.getId(), user.getEmailId());

        // Use manual mapping to avoid null values
        return mapEntityToDTO(user);
    }

    /**
     * Generate unique referral code with retry logic
     */
    private String generateUniqueReferralCode() {
        int maxRetries = 5;
        for (int i = 0; i < maxRetries; i++) {
            String code = referralCodeGenerator.generateUniqueCode();

            // Check if code already exists
            if (!userRepository.existsByReferralCode(code)) {
                return code;
            }
        }

        // Fallback: throw exception if unique code generation fails
        throw new RuntimeException(
                "Failed to generate unique referral code after " + maxRetries + " attempts"
        );
    }

    /**
     * Update an existing user
     */
    @Override
    public UserDTO updateUser(UUID id, UserDTO userDTO) {
        validation.validateUpdate(userDTO);

        UserLogin user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found with ID: " + id));

        // Update only mutable fields
        if (userDTO.getFirst_name() != null) {
            user.setFirstName(userDTO.getFirst_name());
        }
        if (userDTO.getLast_name() != null) {
            user.setLastName(userDTO.getLast_name());
        }
        if (userDTO.getProfile_picture_url() != null) {
            user.setProfilePictureUrl(userDTO.getProfile_picture_url());
        }
        if (userDTO.getIs_active() != null) {
            user.setIsActive(userDTO.getIs_active());
        }

        user = userRepository.save(user);
        return mapEntityToDTO(user);
    }

    /**
     * Get user by ID
     */
    @Override
    public UserDTO getUserById(UUID id) {
        UserLogin user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found with ID: " + id));
        return mapEntityToDTO(user);
    }

    /**
     * Get all users
     */
    @Override
    public List<UserDTO> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::mapEntityToDTO)
                .collect(Collectors.toList());
    }

    /**
     * User login with email and password
     */
    @Override
    public UserDTO login(UserDTO userDTO) {
        validation.validateLogin(userDTO);


        // database call to register user
        Optional<UserLogin> userOpt = userRepository.findByEmailId(userDTO.getEmail_id());

        if (userOpt.isEmpty()) {
            throw new RuntimeException("Invalid email or password");
        }

        UserLogin user = userOpt.get();

        // Verify password
        if (!passwordEncoder.matches(userDTO.getPassword_hash(), user.getPasswordHash())) {
            throw new RuntimeException("Invalid email or password");
        }

        // Check if user is active
        if (!user.getIsActive()) {
            throw new RuntimeException("User account is inactive");
        }

        return mapEntityToDTO(user);
    }

    /**
     * Get user by referral code
     */
    @Override
    public UserDTO getUserByReferralCode(String referralCode) {
        UserLogin user = userRepository.findByReferralCode(referralCode)
                .orElseThrow(() -> new IllegalArgumentException(
                        "User not found with referral code: " + referralCode
                ));
        return mapEntityToDTO(user);
    }

    /**
     * Get all users referred by a specific user
     */
    @Override
    public List<UserDTO> getUsersReferredBy(UUID userId) {
        // Verify the user exists
        userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found with ID: " + userId));

        return userRepository.findByReferredById(userId).stream()
                .map(this::mapEntityToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get total referral count for a user
     */
    @Override
    public Long getReferralCount(UUID userId) {
        // Verify the user exists
        userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found with ID: " + userId));

        return userRepository.countReferralsByUserId(userId);
    }

    /**
     * Get active referral count for a user
     */
    @Override
    public Long getActiveReferralCount(UUID userId) {
        // Verify the user exists
        userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found with ID: " + userId));

        return userRepository.countActiveReferrals(userId);
    }

    /**
     * ================================================================
     * MANUAL MAPPING METHOD - Converts UserLogin Entity to UserDTO
     * This avoids null values caused by ModelMapper field name mismatch
     * ================================================================
     */
    private UserDTO mapEntityToDTO(UserLogin user) {
        if (user == null) {
            return null;
        }

        UserDTO dto = new UserDTO();

        // Direct field mapping - Entity (camelCase) to DTO (snake_case)
        dto.setId(user.getId());
        dto.setEmail_id(user.getEmailId());
        dto.setUsername(user.getUsername());
        dto.setFirst_name(user.getFirstName());
        dto.setLast_name(user.getLastName());
        dto.setPassword_hash(user.getPasswordHash());
        dto.setIs_active(user.getIsActive());
        dto.setReferral_code(user.getReferralCode());
        dto.setProfile_picture_url(user.getProfilePictureUrl());
        dto.setCreated_at(user.getCreatedAt());
        dto.setUpdated_at(user.getUpdatedAt());

        // Handle referred_by relationship
        if (user.getReferredBy() != null) {
            dto.setReferred_by_id(user.getReferredBy().getId());
        }

        return dto;
    }
}