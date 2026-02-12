package com.snatchmart.snatchmart.exception;

/**
 * Thrown when a user is not found by ID (e.g. after DB reset or invalid/stale token).
 * Mapped to HTTP 404 Not Found.
 */
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(String message) {
        super(message);
    }
}
