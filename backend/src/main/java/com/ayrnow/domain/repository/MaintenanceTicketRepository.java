package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.MaintenanceTicket;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface MaintenanceTicketRepository extends JpaRepository<MaintenanceTicket, UUID> {

    @Query("SELECT t FROM MaintenanceTicket t WHERE t.accountId = :accountId " +
            "AND (:propertyId IS NULL OR t.propertyId = :propertyId) " +
            "AND (:unitId IS NULL OR t.unitId = :unitId) " +
            "AND (:status IS NULL OR t.status = :status) " +
            "ORDER BY t.createdAt DESC")
    Page<MaintenanceTicket> findByAccountWithFilters(
            @Param("accountId") UUID accountId,
            @Param("propertyId") UUID propertyId,
            @Param("unitId") UUID unitId,
            @Param("status") String status,
            Pageable pageable);

    Optional<MaintenanceTicket> findByAccountIdAndId(UUID accountId, UUID id);
}
