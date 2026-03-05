package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.ContractorAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ContractorAssignmentRepository extends JpaRepository<ContractorAssignment, UUID> {

    List<ContractorAssignment> findByAccountIdAndContractorIdOrderByAssignedAtDesc(UUID accountId, UUID contractorId);

    @Query("SELECT a FROM ContractorAssignment a WHERE a.accountId = :accountId AND a.ticketId = :ticketId AND a.status != 'canceled'")
    Optional<ContractorAssignment> findActiveByAccountAndTicket(@Param("accountId") UUID accountId, @Param("ticketId") UUID ticketId);

    Optional<ContractorAssignment> findByAccountIdAndId(UUID accountId, UUID id);
}
