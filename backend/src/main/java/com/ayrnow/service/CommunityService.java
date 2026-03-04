package com.ayrnow.service;

import com.ayrnow.domain.CommunityComment;
import com.ayrnow.domain.CommunityPost;
import com.ayrnow.domain.Membership;
import com.ayrnow.domain.User;
import com.ayrnow.dto.*;
import com.ayrnow.error.ResourceNotFoundException;
import com.ayrnow.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class CommunityService {

    private final CommunityPostRepository postRepository;
    private final CommunityCommentRepository commentRepository;
    private final UserRepository userRepository;
    private final UnitRepository unitRepository;
    private final MembershipRepository membershipRepository;
    private final AccessControlService accessControl;
    private final NotificationService notificationService;

    public CommunityService(CommunityPostRepository postRepository, CommunityCommentRepository commentRepository,
                            UserRepository userRepository, UnitRepository unitRepository,
                            MembershipRepository membershipRepository,
                            AccessControlService accessControl, NotificationService notificationService) {
        this.postRepository = postRepository;
        this.commentRepository = commentRepository;
        this.userRepository = userRepository;
        this.unitRepository = unitRepository;
        this.membershipRepository = membershipRepository;
        this.accessControl = accessControl;
        this.notificationService = notificationService;
    }

    public List<CommunityPostResponse> listPosts(String filter, UUID propertyId, UUID unitId, UUID userId, String role) {
        Set<UUID> propertyIds = accessControl.getAccessiblePropertyIds(userId, role);
        Set<UUID> unitIds = accessControl.getAllAccessibleUnitIds(userId, role);

        List<CommunityPost> posts = new ArrayList<>();
        if ("all".equalsIgnoreCase(filter) || filter == null) {
            posts.addAll(postRepository.findByScopeTypeOrderByCreatedAtDesc("global"));
            if (!propertyIds.isEmpty()) {
                posts.addAll(postRepository.findByScopeTypeAndScopeIdInOrderByCreatedAtDesc("property", new ArrayList<>(propertyIds)));
            }
            if (!unitIds.isEmpty()) {
                posts.addAll(postRepository.findByScopeTypeAndScopeIdInOrderByCreatedAtDesc("unit", new ArrayList<>(unitIds)));
            }
        } else if ("property".equalsIgnoreCase(filter) && propertyId != null) {
            accessControl.ensureCanAccessProperty(userId, role, propertyId);
            posts = postRepository.findByScopeTypeAndScopeIdOrderByCreatedAtDesc("property", propertyId);
        } else if ("unit".equalsIgnoreCase(filter) && unitId != null) {
            accessControl.ensureCanAccessUnit(userId, role, unitId);
            posts = postRepository.findByScopeTypeAndScopeIdOrderByCreatedAtDesc("unit", unitId);
        }
        return posts.stream().sorted(Comparator.comparing(CommunityPost::getCreatedAt).reversed())
                .map(this::toPostResponse).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, String> createPost(CreateCommunityPostRequest req, UUID userId, String role) {
        if (!"landlord".equalsIgnoreCase(role)) throw new org.springframework.security.access.AccessDeniedException("Landlord only");
        if ("property".equals(req.getScopeType()) && req.getScopeId() != null) {
            accessControl.ensureCanAccessProperty(userId, role, req.getScopeId());
        } else if ("unit".equals(req.getScopeType()) && req.getScopeId() != null) {
            accessControl.ensureCanAccessUnit(userId, role, req.getScopeId());
        }

        User author = userRepository.findById(userId).orElseThrow();
        CommunityPost post = new CommunityPost();
        post.setId(UUID.randomUUID());
        post.setScopeType(req.getScopeType());
        post.setScopeId(req.getScopeId());
        post.setAuthorUserId(userId);
        post.setAuthorName(author.getName() != null ? author.getName() : author.getEmail());
        post.setAuthorRole(role);
        post.setTitle(req.getTitle());
        post.setBody(req.getBody());
        post.setPriority(req.getPriority() != null ? req.getPriority() : "info");
        post.setAudience(req.getAudience() != null ? req.getAudience() : "all");
        post.setCommentCount(0);
        post.setCreatedAt(Instant.now());
        post = postRepository.save(post);

        notifyAffectedUsers(post, "New community post: " + post.getTitle());
        return Map.of("postId", post.getId().toString());
    }

    public List<CommunityCommentResponse> listComments(UUID postId, UUID userId, String role) {
        CommunityPost post = postRepository.findById(postId).orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        ensureCanAccessPost(post, userId, role);
        return commentRepository.findByPostIdOrderByCreatedAtAsc(postId).stream()
                .map(this::toCommentResponse).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, String> addComment(UUID postId, AddCommunityCommentRequest req, UUID userId, String role) {
        CommunityPost post = postRepository.findById(postId).orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        ensureCanAccessPost(post, userId, role);

        User author = userRepository.findById(userId).orElseThrow();
        CommunityComment c = new CommunityComment();
        c.setId(UUID.randomUUID());
        c.setPostId(postId);
        c.setAuthorUserId(userId);
        c.setAuthorName(author.getName() != null ? author.getName() : author.getEmail());
        c.setBody(req.getBody());
        c.setCreatedAt(Instant.now());
        commentRepository.save(c);

        post.setCommentCount(post.getCommentCount() + 1);
        postRepository.save(post);

        Map<String, String> params = new HashMap<>();
        if (post.getScopeId() != null) params.put("scopeId", post.getScopeId().toString());
        notificationService.notifyUser(post.getAuthorUserId(), "comment", "New comment on your post", req.getBody(), "/community", params);
        return Map.of("commentId", c.getId().toString());
    }

    private void ensureCanAccessPost(CommunityPost post, UUID userId, String role) {
        if ("global".equals(post.getScopeType())) return;
        if ("property".equals(post.getScopeType()) && post.getScopeId() != null) {
            accessControl.ensureCanAccessProperty(userId, role, post.getScopeId());
            return;
        }
        if ("unit".equals(post.getScopeType()) && post.getScopeId() != null) {
            accessControl.ensureCanAccessUnit(userId, role, post.getScopeId());
        }
    }

    private void notifyAffectedUsers(CommunityPost post, String title) {
        Set<UUID> targetUserIds = new HashSet<>();
        if ("global".equals(post.getScopeType())) {
            userRepository.findAll().stream().filter(u -> "tenant".equalsIgnoreCase(u.getRole())).forEach(u -> targetUserIds.add(u.getId()));
        } else if ("property".equals(post.getScopeType()) && post.getScopeId() != null) {
            unitRepository.findByPropertyId(post.getScopeId()).forEach(u ->
                    membershipRepository.findByUnitId(u.getId()).forEach(m -> targetUserIds.add(m.getUserId())));
        } else if ("unit".equals(post.getScopeType()) && post.getScopeId() != null) {
            membershipRepository.findByUnitId(post.getScopeId()).forEach(m -> targetUserIds.add(m.getUserId()));
        }
        for (UUID uid : targetUserIds) {
            if (!uid.equals(post.getAuthorUserId())) {
                Map<String, String> params = new HashMap<>();
                params.put("postId", post.getId().toString());
                notificationService.notifyUser(uid, "announcement", title, post.getBody(), "/community", params);
            }
        }
    }

    private CommunityPostResponse toPostResponse(CommunityPost p) {
        return new CommunityPostResponse(
                p.getId().toString(),
                p.getScopeType(),
                p.getScopeId() != null ? p.getScopeId().toString() : null,
                p.getAuthorUserId().toString(),
                p.getAuthorName(),
                p.getAuthorRole(),
                p.getTitle(),
                p.getBody(),
                p.getPriority(),
                p.getAudience(),
                p.getCommentCount(),
                p.getCreatedAt());
    }

    private CommunityCommentResponse toCommentResponse(CommunityComment c) {
        return new CommunityCommentResponse(
                c.getId().toString(),
                c.getPostId().toString(),
                c.getAuthorUserId().toString(),
                c.getAuthorName(),
                c.getBody(),
                c.getCreatedAt());
    }
}
