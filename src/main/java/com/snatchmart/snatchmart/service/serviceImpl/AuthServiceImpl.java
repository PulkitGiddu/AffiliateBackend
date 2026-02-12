package com.snatchmart.snatchmart.service.serviceImpl;

import com.snatchmart.snatchmart.DTO.AuthRequest;
import com.snatchmart.snatchmart.DTO.AuthResponse;
import com.snatchmart.snatchmart.DTO.RegisterRequest;
import com.snatchmart.snatchmart.entity.UserLogin;
import com.snatchmart.snatchmart.repository.UserRepository;
import com.snatchmart.snatchmart.security.JwtService;
import com.snatchmart.snatchmart.service.AuthService;
import com.snatchmart.snatchmart.service.ReferralCodeGenerator;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
@Transactional
public class AuthServiceImpl implements AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthServiceImpl.class);
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final ReferralCodeGenerator referralCodeGenerator;

    public AuthServiceImpl(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            AuthenticationManager authenticationManager,
            ReferralCodeGenerator referralCodeGenerator
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.referralCodeGenerator = referralCodeGenerator;
    }

    @Override
    public AuthResponse register(RegisterRequest request) {
        UserLogin user = UserLogin.builder()
                .emailId(request.getEmail())
                .username(request.getUsername())
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .profilePictureUrl(request.getProfilePictureUrl())
                .referralCode(referralCodeGenerator.generateUniqueCode())
                .isActive(true)
                .build();

        if (request.getReferredByCode() != null && !request.getReferredByCode().isBlank()) {
            userRepository.findByReferralCode(request.getReferredByCode())
                    .ifPresent(user::setReferredBy);
        }

        UserLogin saved = userRepository.save(user);
        String token = jwtService.generateToken(saved.getEmailId(), Map.of("role", "USER"));
        return AuthResponse.builder()
                .userId(saved.getId())
                .email(saved.getEmailId())
                .token(token)
                .build();
    }

    @Override
    public AuthResponse login(AuthRequest request) {
        log.info("AuthService.login: email={}", request.getEmail());
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );
        UserLogin user = userRepository.findByEmailId(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        log.info("AuthService.login user found and authenticated: id={}, email={}", user.getId(), user.getEmailId());
        String token = jwtService.generateToken(user.getEmailId(), Map.of("role", "USER"));
        return AuthResponse.builder()
                .userId(user.getId())
                .email(user.getEmailId())
                .token(token)
                .build();
    }
}
