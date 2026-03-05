package com.ayrnow.repository;

import com.ayrnow.domain.Property;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PropertyRepository extends JpaRepository<Property, UUID> {
    List<Property> findByOwnerUserId(UUID ownerUserId);
}
