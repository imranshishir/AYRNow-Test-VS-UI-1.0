package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AppUserRepository extends JpaRepository<AppUser, UUID> {

    Optional<AppUser> findByAccountIdAndId(UUID accountId, UUID id);

    Optional<AppUser> findByEmail(String email);

    List<AppUser> findByAccountId(UUID accountId);
}
