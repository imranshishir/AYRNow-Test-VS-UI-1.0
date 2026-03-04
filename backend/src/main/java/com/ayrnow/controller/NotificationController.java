package com.ayrnow.controller;

import com.ayrnow.dto.NotificationResponse;
import com.ayrnow.service.NotificationService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public List<NotificationResponse> list(@RequestParam(defaultValue = "false") boolean unreadOnly, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        return notificationService.list(userId, unreadOnly);
    }

    @PostMapping("/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markRead(@PathVariable UUID id, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        notificationService.markRead(id, userId);
    }

    @PostMapping("/mark-all-read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markAllRead(Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        notificationService.markAllRead(userId);
    }
}
