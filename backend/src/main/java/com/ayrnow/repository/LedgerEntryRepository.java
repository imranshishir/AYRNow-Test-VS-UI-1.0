package com.ayrnow.repository;

import com.ayrnow.domain.LedgerEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface LedgerEntryRepository extends JpaRepository<LedgerEntry, UUID> {

    List<LedgerEntry> findByUnitIdOrderByCreatedAtDesc(UUID unitId);

    @Query("SELECT COALESCE(SUM(l.amountCents), 0) FROM LedgerEntry l WHERE l.unitId = :unitId AND l.entryType = 'charge' AND l.createdAt >= :since")
    int sumChargesForUnitSince(UUID unitId, Instant since);

    @Query("SELECT COALESCE(SUM(l.amountCents), 0) FROM LedgerEntry l WHERE l.unitId = :unitId AND l.entryType = 'payment' AND l.createdAt >= :since")
    int sumPaymentsForUnitSince(UUID unitId, Instant since);
}
