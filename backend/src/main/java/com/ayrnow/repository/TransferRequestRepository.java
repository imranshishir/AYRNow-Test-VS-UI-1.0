package com.ayrnow.repository;

import com.ayrnow.domain.TransferRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TransferRequestRepository extends JpaRepository<TransferRequest, UUID> {
    Optional<TransferRequest> findFirstByTenantUserIdAndStatusOrderByCreatedAtDesc(UUID tenantUserId, String status);
    List<TransferRequest> findAllByOrderByCreatedAtDesc();
}
