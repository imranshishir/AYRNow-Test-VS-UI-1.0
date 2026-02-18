package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.PaymentRecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface PaymentRecordRepository extends JpaRepository<PaymentRecord, UUID> {

    @Query("SELECT p FROM PaymentRecord p WHERE p.accountId = :accountId " +
            "AND (:unitId IS NULL OR p.unitId = :unitId) " +
            "AND (:leaseId IS NULL OR p.leaseId = :leaseId) " +
            "ORDER BY p.createdAt DESC")
    Page<PaymentRecord> findByAccountWithFilters(
            @Param("accountId") UUID accountId,
            @Param("unitId") UUID unitId,
            @Param("leaseId") UUID leaseId,
            Pageable pageable);

    Optional<PaymentRecord> findByAccountIdAndId(UUID accountId, UUID id);
    Optional<PaymentRecord> findByStripeCheckoutSessionId(String stripeCheckoutSessionId);
    Optional<PaymentRecord> findByStripePaymentIntentId(String stripePaymentIntentId);
}
