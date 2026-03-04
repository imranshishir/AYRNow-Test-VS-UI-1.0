package com.ayrnow.repository;

import com.ayrnow.domain.CommunityComment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface CommunityCommentRepository extends JpaRepository<CommunityComment, UUID> {
    List<CommunityComment> findByPostIdOrderByCreatedAtAsc(UUID postId);
}
