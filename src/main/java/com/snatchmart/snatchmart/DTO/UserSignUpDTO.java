package com.snatchmart.snatchmart.DTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserSignUpDTO {
    private String id;
    private String email_id;
    private String username;
    private String first_name;
    private String last_name;
    private String password_hash;
    private Boolean is_active;
    private String referred_by_id;  // will use this later to track referrals.
    private String profile_picture_url;
    private LocalDateTime created_at;
    private LocalDateTime updated_at;
}
