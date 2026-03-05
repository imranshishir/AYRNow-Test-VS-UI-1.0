package com.ayrnow.service;

import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.CommunityPost;
import com.ayrnow.domain.entity.PostComment;
import com.ayrnow.domain.repository.CommunityPostRepository;
import com.ayrnow.domain.repository.PostCommentRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class PostCommentService {

    private final PostCommentRepository commentRepository;
    private final CommunityPostService postService;

    public PostCommentService(PostCommentRepository commentRepository, CommunityPostService postService) {
        this.commentRepository = commentRepository;
        this.postService = postService;
    }

    public List<PostComment> getComments(UUID accountId, UUID postId, UUID principalUserId, String principalRole) {
        CommunityPost post = postService.getById(accountId, postId, principalUserId, principalRole);
        return commentRepository.findByAccountIdAndPostIdOrderByCreatedAtAsc(accountId, post.getId());
    }

    @Transactional
    public PostComment addComment(UUID accountId, UUID postId, UUID principalUserId, String principalRole, String body) {
        CommunityPost post = postService.getById(accountId, postId, principalUserId, principalRole);
        PostComment c = new PostComment();
        c.setAccountId(accountId);
        c.setPostId(post.getId());
        c.setUserId(principalUserId);
        c.setBody(body);
        return commentRepository.save(c);
    }
}
