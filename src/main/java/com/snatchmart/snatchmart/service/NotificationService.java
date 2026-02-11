package com.snatchmart.snatchmart.service;

import com.snatchmart.snatchmart.DTO.NotificationResponse;

import java.util.List;
import java.util.UUID;

public interface NotificationService {
    List<NotificationResponse> getByUser(UUID userId);
    NotificationResponse markRead(UUID notificationId);
}
