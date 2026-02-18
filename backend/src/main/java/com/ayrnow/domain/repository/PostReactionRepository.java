package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.PostReaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PostReactionRepository extends JpaRepository<PostReaction, PostReaction.PostReactionId> {

    Optional<PostReaction> findByPostIdAndUserId(UUID postId, UUID userId);

    List<PostReaction> findByAccountIdAndPostId(UUID accountId, UUID postId);

    long countByPostId(UUID postId);
}
