package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.UnitMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UnitMemberRepository extends JpaRepository<UnitMember, UnitMember.UnitMemberId> {

    List<UnitMember> findByAccountIdAndUnitIdOrderByAddedAtAsc(UUID accountId, UUID unitId);

    List<UnitMember> findByAccountIdAndUserId(UUID accountId, UUID userId);

    boolean existsByAccountIdAndUnitIdAndUserId(UUID accountId, UUID unitId, UUID userId);
}
