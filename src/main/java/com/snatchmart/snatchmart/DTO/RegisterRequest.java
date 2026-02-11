package com.snatchmart.snatchmart.DTO;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RegisterRequest {
    @Email
    @NotBlank
    private String email;

    @NotBlank
    private String username;

    private String firstName;
    private String lastName;

    @NotBlank
    private String password;

    private String referredByCode;
    private String profilePictureUrl;
}
