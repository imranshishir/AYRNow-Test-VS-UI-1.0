package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.WebhookEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface WebhookEventRepository extends JpaRepository<WebhookEvent, UUID> {

    Optional<WebhookEvent> findByStripeEventId(String stripeEventId);
}
