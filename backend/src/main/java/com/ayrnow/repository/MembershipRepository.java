package com.ayrnow.repository;

import com.ayrnow.domain.Membership;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MembershipRepository extends JpaRepository<Membership, UUID> {
    List<Membership> findByUnitId(UUID unitId);
    List<Membership> findByUserId(UUID userId);
    Optional<Membership> findByUnitIdAndUserId(UUID unitId, UUID userId);
}
