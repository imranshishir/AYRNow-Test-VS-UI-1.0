package com.ayrnow.repository;

import com.ayrnow.domain.HouseholdMember;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface HouseholdMemberRepository extends JpaRepository<HouseholdMember, UUID> {
    List<HouseholdMember> findByUnitIdOrderByCreatedAtAsc(UUID unitId);
    Optional<HouseholdMember> findByUnitIdAndEmail(UUID unitId, String email);
}
