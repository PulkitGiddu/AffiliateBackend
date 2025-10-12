package com.snatchmart.snatchmart.DTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserDTO {
    private UUID id;
    private String email_id;
    private String username;
    private String first_name;
    private String last_name;
    private String password_hash;
    private Boolean is_active;

    // Referral system fields
    private String referral_code;           // AUTO-GENERATED (returned to user)
    private String referred_by_code;        // INPUT: Code they received from referrer
    private UUID referred_by_id;            // OUTPUT: ID of the user who referred them

    private String profile_picture_url;
    private OffsetDateTime created_at;
    private OffsetDateTime updated_at;
}