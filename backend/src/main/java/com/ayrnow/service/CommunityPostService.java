package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.api.dto.PostResponse;
import com.ayrnow.domain.entity.CommunityPost;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.domain.repository.CommunityPostRepository;
import com.ayrnow.domain.repository.PostCommentRepository;
import com.ayrnow.domain.repository.PostReactionRepository;
import com.ayrnow.domain.repository.PropertyRepository;
import com.ayrnow.domain.repository.UnitRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class CommunityPostService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");
    private static final Set<String> TENANT_LIKE_ROLES = Set.of("tenant", "family", "cotenant", "co_tenant");
    private static final Set<String> POST_KINDS = Set.of("announcement", "event", "alert");

    private final CommunityPostRepository postRepository;
    private final PostCommentRepository commentRepository;
    private final PostReactionRepository reactionRepository;
    private final UnitRepository unitRepository;
    private final PropertyRepository propertyRepository;
    private final UnitMemberService unitMemberService;
    private final NotificationService notificationService;

    public CommunityPostService(CommunityPostRepository postRepository,
                               PostCommentRepository commentRepository,
                               PostReactionRepository reactionRepository,
                               UnitRepository unitRepository,
                               PropertyRepository propertyRepository,
                               UnitMemberService unitMemberService,
                               NotificationService notificationService) {
        this.postRepository = postRepository;
        this.commentRepository = commentRepository;
        this.reactionRepository = reactionRepository;
        this.unitRepository = unitRepository;
        this.propertyRepository = propertyRepository;
        this.unitMemberService = unitMemberService;
        this.notificationService = notificationService;
    }

    private boolean isStaff(String role) {
        return STAFF_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    private boolean canUserSeePost(CommunityPost post, UUID principalUserId, String principalRole) {
        if (isStaff(principalRole)) return true;
        if (!TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            return false;
        }
        if (post.getPropertyId() == null) return true;
        var scope = unitMemberService.getTenantScope(post.getAccountId(), principalUserId);
        if (!scope.propertyIds().contains(post.getPropertyId())) return false;
        if (post.getUnitId() == null) return true;
        return scope.unitIds().contains(post.getUnitId());
    }

    public Page<CommunityPost> list(UUID accountId, UUID propertyId, UUID unitId, String kind, int page, int size, UUID principalUserId, String principalRole) {
        Page<CommunityPost> posts = postRepository.findByAccountWithFilters(
                accountId, propertyId, unitId, kind,
                PageRequest.of(page, Math.min(size, 100)));
        if (isStaff(principalRole)) return posts;
        if (TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            List<CommunityPost> filtered = posts.getContent().stream()
                    .filter(p -> canUserSeePost(p, principalUserId, principalRole))
                    .toList();
            return new PageImpl<>(filtered, posts.getPageable(), filtered.size());
        }
        return posts;
    }

    public CommunityPost getById(UUID accountId, UUID postId, UUID principalUserId, String principalRole) {
        CommunityPost post = postRepository.findByAccountIdAndId(accountId, postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        if (!canUserSeePost(post, principalUserId, principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        return post;
    }

    @Transactional
    public CommunityPost create(UUID accountId, UUID principalUserId, String principalRole,
                               UUID propertyId, UUID unitId, String title, String body, String kind) {
        if (!isStaff(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        String resolvedKind = (kind != null && !kind.isBlank()) ? kind.toLowerCase() : "announcement";
        if (!POST_KINDS.contains(resolvedKind)) {
            throw new ConflictException("Invalid kind: must be announcement, event, or alert");
        }
        if (propertyId != null) {
            propertyRepository.findByAccountIdAndId(accountId, propertyId)
                    .orElseThrow(() -> new ResourceNotFoundException("Property not found"));
        }
        if (unitId != null) {
            Unit unit = unitRepository.findByAccountIdAndId(accountId, unitId)
                    .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
            if (propertyId != null && !unit.getPropertyId().equals(propertyId)) {
                throw new ConflictException("Unit does not belong to property");
            }
        }
        CommunityPost post = new CommunityPost();
        post.setAccountId(accountId);
        post.setPropertyId(propertyId);
        post.setUnitId(unitId);
        post.setAuthorUserId(principalUserId);
        post.setTitle(title != null ? title.trim() : null);
        post.setBody(body.trim());
        post.setKind(resolvedKind);
        post = postRepository.save(post);
        notificationService.createForNewPost(post);
        return post;
    }

    public PostResponse toResponse(CommunityPost post) {
        long commentCount = commentRepository.countByPostId(post.getId());
        long reactionCount = reactionRepository.countByPostId(post.getId());
        return PostResponse.from(post, commentCount, reactionCount);
    }
}
