package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    Page<Notification> findByAccountIdAndUserIdOrderByCreatedAtDesc(UUID accountId, UUID userId, Pageable pageable);

    Optional<Notification> findByAccountIdAndIdAndUserId(UUID accountId, UUID id, UUID userId);

    List<Notification> findByAccountIdAndUserIdAndIdIn(UUID accountId, UUID userId, List<UUID> ids);
}
