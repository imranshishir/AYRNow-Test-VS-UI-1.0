package com.ayrnow.service;

import com.ayrnow.domain.Notification;
import com.ayrnow.dto.NotificationResponse;
import com.ayrnow.error.ResourceNotFoundException;
import com.ayrnow.repository.NotificationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public NotificationService(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    @Transactional
    public void notifyUser(UUID targetUserId, String type, String title, String body, String route, Map<String, String> params) {
        Notification n = new Notification();
        n.setId(UUID.randomUUID());
        n.setTargetUserId(targetUserId);
        n.setType(type);
        n.setTitle(title);
        n.setBody(body);
        n.setRoute(route != null ? route : "/L-30");
        n.setParams(params != null ? params : new HashMap<>());
        n.setRead(false);
        n.setCreatedAt(Instant.now());
        notificationRepository.save(n);
    }

    public List<NotificationResponse> list(UUID userId, boolean unreadOnly) {
        List<Notification> list = unreadOnly
                ? notificationRepository.findByTargetUserIdAndReadFalseOrderByCreatedAtDesc(userId)
                : notificationRepository.findByTargetUserIdOrderByCreatedAtDesc(userId);
        return list.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public void markRead(UUID id, UUID userId) {
        Notification n = notificationRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Notification not found"));
        if (!n.getTargetUserId().equals(userId)) {
            throw new ResourceNotFoundException("Notification not found");
        }
        n.setRead(true);
        notificationRepository.save(n);
    }

    @Transactional
    public void markAllRead(UUID userId) {
        List<Notification> list = notificationRepository.findByTargetUserIdAndReadFalseOrderByCreatedAtDesc(userId);
        list.forEach(n -> n.setRead(true));
        notificationRepository.saveAll(list);
    }

    private NotificationResponse toResponse(Notification n) {
        Map<String, String> p = n.getParams();
        String propertyId = p != null ? p.get("propertyId") : null;
        String unitId = p != null ? p.get("unitId") : null;
        String targetRole = p != null ? p.get("targetRole") : null;
        return new NotificationResponse(
                n.getId().toString(),
                n.getType(),
                n.getTitle(),
                n.getBody(),
                n.getCreatedAt(),
                n.isRead(),
                n.getRoute(),
                n.getParams(),
                propertyId,
                unitId,
                targetRole != null ? targetRole : "any");
    }
}
