package com.ayrnow.api;

import com.ayrnow.api.dto.*;
import com.ayrnow.domain.entity.CommunityPost;
import com.ayrnow.domain.entity.PostComment;
import com.ayrnow.domain.entity.PostReaction;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.CommunityPostService;
import com.ayrnow.service.PostCommentService;
import com.ayrnow.service.PostReactionService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/posts")
public class PostController {

    private final CommunityPostService postService;
    private final PostCommentService commentService;
    private final PostReactionService reactionService;

    public PostController(CommunityPostService postService, PostCommentService commentService, PostReactionService reactionService) {
        this.postService = postService;
        this.commentService = commentService;
        this.reactionService = reactionService;
    }

    @GetMapping
    public PageResponse<PostResponse> list(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @RequestParam(required = false) UUID propertyId,
            @RequestParam(required = false) UUID unitId,
            @RequestParam(required = false) String kind,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<CommunityPost> posts = postService.list(
                principal.accountId(),
                propertyId,
                unitId,
                kind,
                page,
                size,
                principal.userId(),
                principal.role()
        );
        return PageResponse.from(posts.map(postService::toResponse));
    }

    @PostMapping
    public ResponseEntity<PostResponse> create(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @Valid @RequestBody CreatePostRequest req) {
        CommunityPost post = postService.create(
                principal.accountId(),
                principal.userId(),
                principal.role(),
                req.propertyId(),
                req.unitId(),
                req.title(),
                req.body(),
                req.kind()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(postService.toResponse(post));
    }

    @GetMapping("/{postId}")
    public PostResponse getById(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID postId) {
        CommunityPost post = postService.getById(
                principal.accountId(),
                postId,
                principal.userId(),
                principal.role()
        );
        return postService.toResponse(post);
    }

    @PostMapping("/{postId}/comments")
    public ResponseEntity<CommentResponse> addComment(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID postId,
            @Valid @RequestBody CreateCommentRequest req) {
        PostComment c = commentService.addComment(
                principal.accountId(),
                postId,
                principal.userId(),
                principal.role(),
                req.body()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(CommentResponse.from(c));
    }

    @GetMapping("/{postId}/comments")
    public List<CommentResponse> getComments(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID postId) {
        List<PostComment> comments = commentService.getComments(
                principal.accountId(),
                postId,
                principal.userId(),
                principal.role()
        );
        return comments.stream().map(CommentResponse::from).toList();
    }

    @PostMapping("/{postId}/reactions")
    public ReactionResponse setReaction(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID postId,
            @Valid @RequestBody SetReactionRequest req) {
        PostReaction r = reactionService.setReaction(
                principal.accountId(),
                postId,
                principal.userId(),
                principal.role(),
                req.reaction()
        );
        return ReactionResponse.from(r);
    }
}
