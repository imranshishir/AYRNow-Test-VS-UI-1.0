package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.Lease;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface LeaseRepository extends JpaRepository<Lease, UUID> {

    @Query("SELECT l FROM Lease l WHERE l.accountId = :accountId AND l.tenantUserId = :tenantUserId AND l.status = 'active' ORDER BY l.createdAt DESC")
    List<Lease> findActiveByAccountAndTenant(@Param("accountId") UUID accountId, @Param("tenantUserId") UUID tenantUserId, Pageable pageable);

    @Query("SELECT l FROM Lease l WHERE l.unitId = :unitId AND l.status = 'active'")
    List<Lease> findActiveByUnitId(@Param("unitId") UUID unitId);

    @Query("SELECT l FROM Lease l WHERE l.accountId = :accountId " +
            "AND (:status IS NULL OR l.status = :status) " +
            "AND (:unitId IS NULL OR l.unitId = :unitId) " +
            "ORDER BY l.createdAt DESC")
    Page<Lease> findByAccountWithFilters(@Param("accountId") UUID accountId, @Param("status") String status, @Param("unitId") UUID unitId, Pageable pageable);

    Optional<Lease> findByAccountIdAndId(UUID accountId, UUID id);
}
