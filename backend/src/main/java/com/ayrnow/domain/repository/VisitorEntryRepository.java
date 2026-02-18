package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.VisitorEntry;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface VisitorEntryRepository extends JpaRepository<VisitorEntry, UUID> {

    @Query("SELECT v FROM VisitorEntry v WHERE v.accountId = :accountId " +
            "AND (:propertyId IS NULL OR v.propertyId = :propertyId) " +
            "AND (:unitId IS NULL OR v.unitId = :unitId) " +
            "AND (:status IS NULL OR :status = '' OR v.status = :status) " +
            "ORDER BY v.createdAt DESC")
    Page<VisitorEntry> findByAccountWithFilters(
            @Param("accountId") UUID accountId,
            @Param("propertyId") UUID propertyId,
            @Param("unitId") UUID unitId,
            @Param("status") String status,
            Pageable pageable);

    Optional<VisitorEntry> findByAccountIdAndId(UUID accountId, UUID id);
}
