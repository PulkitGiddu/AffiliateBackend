package com.snatchmart.snatchmart.validator;

import com.snatchmart.snatchmart.DTO.UserDTO;
import org.springframework.stereotype.Component;

@Component
public class UserSignUpValidation {
    public void validateSignUp(UserDTO userDTO) {
        if (userDTO.getEmail_id() == null || userDTO.getEmail_id().isEmpty()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (userDTO.getPassword_hash() == null || userDTO.getPassword_hash().isEmpty()) {
            throw new IllegalArgumentException("Password is required");
        }
        if (userDTO.getUsername() == null || userDTO.getUsername().isEmpty()) {
            throw new IllegalArgumentException("Username is required");
        }
    }

    public void validateUpdate(UserDTO userDTO) {
        if (userDTO.getId() == null) {
            throw new IllegalArgumentException("User ID is required for update");
        }
    }

    public void validateLogin(UserDTO userDTO) {
        if (userDTO.getEmail_id() == null || userDTO.getEmail_id().isEmpty()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (userDTO.getPassword_hash() == null || userDTO.getPassword_hash().isEmpty()) {
            throw new IllegalArgumentException("Password is required");
        }
    }
}
