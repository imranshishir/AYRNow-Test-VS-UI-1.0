package com.ayrnow.api;

import com.ayrnow.api.dto.MarkReadRequest;
import com.ayrnow.api.dto.NotificationResponse;
import com.ayrnow.api.dto.PageResponse;
import com.ayrnow.domain.entity.Notification;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.NotificationService;
import org.springframework.data.domain.Page;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public PageResponse<NotificationResponse> list(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<Notification> notifications = notificationService.list(
                principal.accountId(),
                principal.userId(),
                page,
                size
        );
        return PageResponse.from(notifications.map(NotificationResponse::from));
    }

    @PostMapping("/read")
    public void markRead(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @RequestBody(required = false) MarkReadRequest req) {
        if (req == null) {
            return;
        }
        boolean all = Boolean.TRUE.equals(req.all());
        notificationService.markRead(
                principal.accountId(),
                principal.userId(),
                req.notificationIds(),
                all
        );
    }
}
