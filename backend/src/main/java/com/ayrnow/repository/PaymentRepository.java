package com.ayrnow.repository;

import com.ayrnow.domain.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {

    @Query("SELECT COUNT(p) > 0 FROM Payment p WHERE p.unitId = :unitId AND p.status IN ('succeeded', 'stubbed') AND p.createdAt >= :since")
    boolean existsSucceededForUnitSince(UUID unitId, Instant since);

    List<Payment> findByTenantUserIdOrderByCreatedAtDesc(UUID tenantUserId);
}
