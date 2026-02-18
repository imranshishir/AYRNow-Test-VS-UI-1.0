package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.CommunityPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CommunityPostRepository extends JpaRepository<CommunityPost, UUID> {

    @Query("SELECT p FROM CommunityPost p WHERE p.accountId = :accountId " +
            "AND (:propertyId IS NULL OR p.propertyId = :propertyId) " +
            "AND (:unitId IS NULL OR p.unitId = :unitId) " +
            "AND (:kind IS NULL OR :kind = '' OR p.kind = :kind) " +
            "ORDER BY p.createdAt DESC")
    Page<CommunityPost> findByAccountWithFilters(
            @Param("accountId") UUID accountId,
            @Param("propertyId") UUID propertyId,
            @Param("unitId") UUID unitId,
            @Param("kind") String kind,
            Pageable pageable);

    Optional<CommunityPost> findByAccountIdAndId(UUID accountId, UUID id);
}
