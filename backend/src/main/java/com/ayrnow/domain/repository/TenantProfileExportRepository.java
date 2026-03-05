package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.TenantProfileExport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TenantProfileExportRepository extends JpaRepository<TenantProfileExport, UUID> {

    Optional<TenantProfileExport> findByShareToken(String shareToken);

    List<TenantProfileExport> findByTenantUserIdOrderByCreatedAtDesc(UUID tenantUserId, org.springframework.data.domain.Pageable pageable);
}
