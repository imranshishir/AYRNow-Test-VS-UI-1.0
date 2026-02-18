package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserRoleRepository extends JpaRepository<UserRole, com.ayrnow.domain.entity.UserRoleId> {

    List<UserRole> findByUserId(UUID userId);
}
