package com.ayrnow.repository;

import com.ayrnow.domain.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByTargetUserIdOrderByCreatedAtDesc(UUID targetUserId);
    List<Notification> findByTargetUserIdAndReadFalseOrderByCreatedAtDesc(UUID targetUserId);
}
