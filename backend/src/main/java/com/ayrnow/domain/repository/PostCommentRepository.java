package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.PostComment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PostCommentRepository extends JpaRepository<PostComment, UUID> {

    List<PostComment> findByAccountIdAndPostIdOrderByCreatedAtAsc(UUID accountId, UUID postId);

    long countByPostId(UUID postId);
}
