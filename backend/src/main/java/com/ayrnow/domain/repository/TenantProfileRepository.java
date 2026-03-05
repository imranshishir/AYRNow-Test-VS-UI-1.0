package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.TenantProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface TenantProfileRepository extends JpaRepository<TenantProfile, UUID> {

    Optional<TenantProfile> findByUserId(UUID userId);
}
