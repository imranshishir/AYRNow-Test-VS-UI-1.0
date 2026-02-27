package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.Unit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UnitRepository extends JpaRepository<Unit, UUID> {

    List<Unit> findByAccountIdAndPropertyIdOrderByUnitLabel(UUID accountId, UUID propertyId);

    java.util.Optional<Unit> findByAccountIdAndId(UUID accountId, UUID id);
}
