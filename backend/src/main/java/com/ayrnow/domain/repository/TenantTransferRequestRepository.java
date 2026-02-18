package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.TenantTransferRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TenantTransferRequestRepository extends JpaRepository<TenantTransferRequest, UUID> {

    List<TenantTransferRequest> findByExportIdOrderByRequestedAtDesc(UUID exportId);

    Optional<TenantTransferRequest> findByExportIdAndRequestingAccountIdAndStatus(UUID exportId, UUID requestingAccountId, String status);

    @Query("SELECT r FROM TenantTransferRequest r WHERE r.exportId = :exportId AND r.requestingAccountId = :accountId AND r.status = 'pending'")
    Optional<TenantTransferRequest> findPendingByExportAndAccount(@Param("exportId") UUID exportId, @Param("accountId") UUID accountId);

    @Query("SELECT r FROM TenantTransferRequest r WHERE r.exportId = :exportId AND r.requestingAccountId = :accountId AND r.status = 'approved'")
    Optional<TenantTransferRequest> findApprovedByExportAndAccount(@Param("exportId") UUID exportId, @Param("accountId") UUID accountId);
}
