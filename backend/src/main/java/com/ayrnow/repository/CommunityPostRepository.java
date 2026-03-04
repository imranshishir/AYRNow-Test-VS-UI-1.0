package com.ayrnow.repository;

import com.ayrnow.domain.CommunityPost;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface CommunityPostRepository extends JpaRepository<CommunityPost, UUID> {
    List<CommunityPost> findByScopeTypeAndScopeIdOrderByCreatedAtDesc(String scopeType, UUID scopeId);
    List<CommunityPost> findByScopeTypeOrderByCreatedAtDesc(String scopeType);
    List<CommunityPost> findByScopeTypeAndScopeIdInOrderByCreatedAtDesc(String scopeType, java.util.List<UUID> scopeIds);
}
