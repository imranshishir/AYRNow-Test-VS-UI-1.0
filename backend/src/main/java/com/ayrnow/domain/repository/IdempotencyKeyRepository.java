package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.IdempotencyKeyRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface IdempotencyKeyRepository extends JpaRepository<IdempotencyKeyRecord, IdempotencyKeyRecord.IdempotencyKeyId> {

    Optional<IdempotencyKeyRecord> findByAccountIdAndKeyAndEndpoint(UUID accountId, String key, String endpoint);
}
