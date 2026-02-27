package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.Property;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PropertyRepository extends JpaRepository<Property, UUID> {

    List<Property> findByAccountIdOrderByCreatedAtDesc(UUID accountId);

    java.util.Optional<Property> findByAccountIdAndId(UUID accountId, UUID id);
}
