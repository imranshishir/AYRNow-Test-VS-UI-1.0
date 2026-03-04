package com.ayrnow.controller;

import com.ayrnow.dto.*;
import com.ayrnow.repository.UserRepository;
import com.ayrnow.service.CommunityService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/community")
public class CommunityController {

    private final CommunityService communityService;
    private final UserRepository userRepository;

    public CommunityController(CommunityService communityService, UserRepository userRepository) {
        this.communityService = communityService;
        this.userRepository = userRepository;
    }

    @GetMapping("/posts")
    public List<CommunityPostResponse> listPosts(
            @RequestParam(defaultValue = "all") String filter,
            @RequestParam(required = false) UUID propertyId,
            @RequestParam(required = false) UUID unitId,
            Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return communityService.listPosts(filter, propertyId, unitId, userId, role);
    }

    @PostMapping("/posts")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, String> createPost(@Valid @RequestBody CreateCommunityPostRequest request, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return communityService.createPost(request, userId, role);
    }

    @GetMapping("/posts/{postId}/comments")
    public List<CommunityCommentResponse> listComments(@PathVariable UUID postId, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return communityService.listComments(postId, userId, role);
    }

    @PostMapping("/posts/{postId}/comments")
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, String> addComment(@PathVariable UUID postId, @Valid @RequestBody AddCommunityCommentRequest request, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return communityService.addComment(postId, request, userId, role);
    }
}
