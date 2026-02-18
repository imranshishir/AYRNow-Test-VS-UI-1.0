package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.CommunityPost;
import com.ayrnow.domain.entity.PostReaction;
import com.ayrnow.domain.repository.CommunityPostRepository;
import com.ayrnow.domain.repository.PostReactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.Set;
import java.util.UUID;

@Service
public class PostReactionService {

    private static final Set<String> VALID_REACTIONS = Set.of("like", "love", "laugh", "sad", "angry");

    private final PostReactionRepository reactionRepository;
    private final CommunityPostService postService;

    public PostReactionService(PostReactionRepository reactionRepository, CommunityPostService postService) {
        this.reactionRepository = reactionRepository;
        this.postService = postService;
    }

    @Transactional
    public PostReaction setReaction(UUID accountId, UUID postId, UUID principalUserId, String principalRole, String reaction) {
        CommunityPost post = postService.getById(accountId, postId, principalUserId, principalRole);
        String r = (reaction != null ? reaction : "").toLowerCase().trim();
        if (!VALID_REACTIONS.contains(r)) {
            throw new ConflictException("Invalid reaction: must be like, love, laugh, sad, or angry");
        }
        Optional<PostReaction> existing = reactionRepository.findByPostIdAndUserId(postId, principalUserId);
        PostReaction pr;
        if (existing.isPresent()) {
            pr = existing.get();
            pr.setReaction(r);
            pr = reactionRepository.save(pr);
        } else {
            pr = new PostReaction();
            pr.setPostId(postId);
            pr.setUserId(principalUserId);
            pr.setAccountId(accountId);
            pr.setReaction(r);
            pr = reactionRepository.save(pr);
        }
        return pr;
    }
}
