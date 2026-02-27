package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.LedgerEntry;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface LedgerEntryRepository extends JpaRepository<LedgerEntry, UUID> {

    @Query("SELECT e FROM LedgerEntry e WHERE e.accountId = :accountId AND e.unitId = :unitId " +
            "AND (:fromDate IS NULL OR e.occurredOn >= :fromDate) " +
            "AND (:toDate IS NULL OR e.occurredOn <= :toDate) " +
            "ORDER BY e.occurredOn DESC, e.createdAt DESC")
    Page<LedgerEntry> findByAccountAndUnit(
            @Param("accountId") UUID accountId,
            @Param("unitId") UUID unitId,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate,
            Pageable pageable);

    @Query("SELECT e FROM LedgerEntry e WHERE e.accountId = :accountId AND e.leaseId = :leaseId " +
            "AND (:fromDate IS NULL OR e.occurredOn >= :fromDate) " +
            "AND (:toDate IS NULL OR e.occurredOn <= :toDate) " +
            "ORDER BY e.occurredOn DESC, e.createdAt DESC")
    Page<LedgerEntry> findByAccountAndLease(
            @Param("accountId") UUID accountId,
            @Param("leaseId") UUID leaseId,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate,
            Pageable pageable);

    @Query("SELECT e FROM LedgerEntry e WHERE e.accountId = :accountId AND e.unitId = :unitId " +
            "AND e.occurredOn <= :asOfDate")
    List<LedgerEntry> findByAccountAndUnitForBalance(@Param("accountId") UUID accountId,
                                                     @Param("unitId") UUID unitId,
                                                     @Param("asOfDate") LocalDate asOfDate);

    @Query("SELECT e FROM LedgerEntry e WHERE e.accountId = :accountId AND e.leaseId = :leaseId " +
            "AND e.occurredOn <= :asOfDate")
    List<LedgerEntry> findByAccountAndLeaseForBalance(@Param("accountId") UUID accountId,
                                                      @Param("leaseId") UUID leaseId,
                                                      @Param("asOfDate") LocalDate asOfDate);
}
