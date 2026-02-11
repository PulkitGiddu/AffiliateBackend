package com.snatchmart.snatchmart.DTO;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class NotificationResponse {
    private UUID id;
    private UUID userId;
    private String message;
    private Boolean isRead;
    private LocalDateTime createdAt;
}
