package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.TenantReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TenantReviewRepository extends JpaRepository<TenantReview, UUID> {

    List<TenantReview> findByTenantUserIdOrderByCreatedAtDesc(UUID tenantUserId, org.springframework.data.domain.Pageable pageable);

    @Query("SELECT COALESCE(AVG(r.rating), 0) FROM TenantReview r WHERE r.tenantUserId = :tenantUserId")
    Double avgRatingByTenantUserId(@Param("tenantUserId") UUID tenantUserId);

    @Query("SELECT COUNT(r) FROM TenantReview r WHERE r.tenantUserId = :tenantUserId")
    long countByTenantUserId(@Param("tenantUserId") UUID tenantUserId);
}
