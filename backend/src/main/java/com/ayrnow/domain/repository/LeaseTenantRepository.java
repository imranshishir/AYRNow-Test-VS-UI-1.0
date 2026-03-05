package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.LeaseTenant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface LeaseTenantRepository extends JpaRepository<LeaseTenant, LeaseTenant.LeaseTenantId> {

    List<LeaseTenant> findByAccountIdAndLeaseIdOrderByAddedAtAsc(UUID accountId, UUID leaseId);
}
