package com.snatchmart.snatchmart.exception;

/**
 * Thrown when registration fails because email or username is already taken.
 * Mapped to HTTP 409 Conflict.
 */
public class DuplicateUserException extends RuntimeException {
    public DuplicateUserException(String message) {
        super(message);
    }
}
