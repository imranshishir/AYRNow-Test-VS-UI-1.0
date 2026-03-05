package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.PropertySecuritySettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface PropertySecuritySettingsRepository extends JpaRepository<PropertySecuritySettings, UUID> {

    Optional<PropertySecuritySettings> findByAccountIdAndPropertyId(UUID accountId, UUID propertyId);
}
