package com.ayrnow.repository;

import com.ayrnow.domain.UnitInvite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UnitInviteRepository extends JpaRepository<UnitInvite, UUID> {

    Optional<UnitInvite> findByToken(String token);
}
