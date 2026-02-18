package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.Contractor;
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
public interface ContractorRepository extends JpaRepository<Contractor, UUID> {

    @Query("SELECT c FROM Contractor c WHERE c.accountId = :accountId " +
            "AND (:status IS NULL OR c.status = :status) " +
            "AND (:specialty IS NULL OR c.specialty = :specialty) " +
            "ORDER BY c.name ASC")
    Page<Contractor> findByAccountWithFilters(
            @Param("accountId") UUID accountId,
            @Param("status") String status,
            @Param("specialty") String specialty,
            Pageable pageable);

    Optional<Contractor> findByAccountIdAndId(UUID accountId, UUID id);

    List<Contractor> findByAccountIdAndLinkedUserId(UUID accountId, UUID linkedUserId);
}
