package com.snatchmart.snatchmart.service;

import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.Base64;
import java.util.UUID;

@Service
public class ReferralCodeGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int CODE_LENGTH = 8;
    private static final String ALPHANUMERIC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    /**
     * Generates a unique referral code using Base64 URL-safe encoding
     * Example output: "ABC123XY", "K8L9M0N1"
     * Length: 8 characters
     */
    public String generateUniqueCode() {
        byte[] randomBytes = new byte[CODE_LENGTH];
        RANDOM.nextBytes(randomBytes);

        // Use Base64 URL-safe encoding without padding
        String code = Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(randomBytes)
                .substring(0, CODE_LENGTH)
                .toUpperCase();

        return code;
    }

    /**
     * Alternative method: Generate alphanumeric code
     * Example: "ABC12XY9", "PG123KL8"
     * Length: 8 characters
     */
    public String generateAlphanumericCode() {
        StringBuilder code = new StringBuilder(CODE_LENGTH);
        for (int i = 0; i < CODE_LENGTH; i++) {
            int randomIndex = RANDOM.nextInt(ALPHANUMERIC.length());
            code.append(ALPHANUMERIC.charAt(randomIndex));
        }
        return code.toString();
    }

    /**
     * Generate code with prefix
     * Example: "PG_ABC123", "MK_K8L9M0"
     */
    public String generateCodeWithPrefix(String prefix) {
        byte[] randomBytes = new byte[CODE_LENGTH - prefix.length() - 1];
        RANDOM.nextBytes(randomBytes);

        String randomPart = Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(randomBytes)
                .substring(0, CODE_LENGTH - prefix.length() - 1)
                .toUpperCase();

        return prefix + "_" + randomPart;
    }

    /**
     * Generate simple numeric referral code
     * Example: "12345678", "87654321"
     * Length: 8 digits
     */
    public String generateNumericCode() {
        long code = Math.abs(RANDOM.nextLong()) % 100000000L;
        return String.format("%08d", code);
    }

    /**
     * Generate code based on UUID (ensures uniqueness)
     * Example: "ABC1DEF2", "GHI3JKL4"
     * More reliable than random generation
     */
    public String generateCodeFromUUID() {
        UUID uuid = UUID.randomUUID();
        String uuidStr = uuid.toString().replace("-", "").toUpperCase();
        return uuidStr.substring(0, CODE_LENGTH);
    }
}