package com.snatchmart.snatchmart.exception;

import com.snatchmart.snatchmart.DTO.ErrorResponse;
import com.snatchmart.snatchmart.exception.DuplicateUserException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.OffsetDateTime;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DuplicateUserException.class)
    public ResponseEntity<ErrorResponse> handleDuplicateUser(DuplicateUserException ex, HttpServletRequest request) {
        return buildResponse(ex.getMessage(), request.getRequestURI(), HttpStatus.CONFLICT);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrity(DataIntegrityViolationException ex, HttpServletRequest request) {
        String message = ex.getMessage();
        if (message != null) {
            if (message.contains("email_id") || message.contains("email")) {
                message = "This email is already registered. Please sign in.";
            } else if (message.contains("username")) {
                message = "This username is already taken. Please choose another.";
            } else {
                message = "A user with this email or username already exists.";
            }
        } else {
            message = "A user with this email or username already exists.";
        }
        return buildResponse(message, request.getRequestURI(), HttpStatus.CONFLICT);
    }

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(UserNotFoundException ex, HttpServletRequest request) {
        return buildResponse(ex.getMessage(), request.getRequestURI(), HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ErrorResponse> handleBadCredentials(BadCredentialsException ex, HttpServletRequest request) {
        return buildResponse("Invalid email or password", request.getRequestURI(), HttpStatus.UNAUTHORIZED);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgument(IllegalArgumentException ex, HttpServletRequest request) {
        return buildResponse(ex.getMessage(), request.getRequestURI(), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex, HttpServletRequest request) {
        String message = ex.getBindingResult().getFieldErrors().stream()
                .findFirst()
                .map(error -> error.getField() + " " + error.getDefaultMessage())
                .orElse("Validation error");
        return buildResponse(message, request.getRequestURI(), HttpStatus.BAD_REQUEST);
    }

    /** Login/auth failures from UserServiceImpl so the client can show them in the UI. */
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ErrorResponse> handleRuntime(RuntimeException ex, HttpServletRequest request) {
        String msg = ex.getMessage() != null ? ex.getMessage() : "";
        if ("Invalid email or password".equals(msg)) {
            return buildResponse(msg, request.getRequestURI(), HttpStatus.UNAUTHORIZED);
        }
        if ("User account is inactive".equals(msg)) {
            return buildResponse(msg, request.getRequestURI(), HttpStatus.FORBIDDEN);
        }
        return buildResponse("Unexpected error", request.getRequestURI(), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(Exception ex, HttpServletRequest request) {
        return buildResponse("Unexpected error", request.getRequestURI(), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    private ResponseEntity<ErrorResponse> buildResponse(String message, String path, HttpStatus status) {
        return ResponseEntity.status(status).body(ErrorResponse.builder()
                .message(message)
                .path(path)
                .timestamp(OffsetDateTime.now())
                .build());
    }
}
