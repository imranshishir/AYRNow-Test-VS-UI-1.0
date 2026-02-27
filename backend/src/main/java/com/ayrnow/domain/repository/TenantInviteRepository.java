package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.TenantInvite;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface TenantInviteRepository extends JpaRepository<TenantInvite, UUID> {

    Page<TenantInvite> findByAccountIdAndUnitIdOrderByCreatedAtDesc(UUID accountId, UUID unitId, Pageable pageable);

    Optional<TenantInvite> findByAccountIdAndId(UUID accountId, UUID id);

    Optional<TenantInvite> findByInviteUrlToken(String inviteUrlToken);
}
