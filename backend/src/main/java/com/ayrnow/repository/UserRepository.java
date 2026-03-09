package com.ayrnow.repository;

import com.ayrnow.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    Optional<User> findByEmailAndRole(String email, String role);
    Optional<User> findByVerificationTokenHash(String verificationTokenHash);
    Optional<User> findByResetTokenHash(String resetTokenHash);
}
