package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.api.dto.*;
import com.ayrnow.domain.entity.*;
import com.ayrnow.domain.repository.*;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class TenantTransferService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");
    private static final Set<String> TENANT_LIKE_ROLES = Set.of("tenant", "family", "cotenant", "co_tenant");
    private static final int EXPORT_EXPIRY_DAYS = 30;

    private final TenantProfileRepository profileRepository;
    private final TenantReviewRepository reviewRepository;
    private final TenantProfileExportRepository exportRepository;
    private final TenantTransferRequestRepository requestRepository;
    private final AppUserRepository appUserRepository;

    public TenantTransferService(TenantProfileRepository profileRepository,
                                 TenantReviewRepository reviewRepository,
                                 TenantProfileExportRepository exportRepository,
                                 TenantTransferRequestRepository requestRepository,
                                 AppUserRepository appUserRepository) {
        this.profileRepository = profileRepository;
        this.reviewRepository = reviewRepository;
        this.exportRepository = exportRepository;
        this.requestRepository = requestRepository;
        this.appUserRepository = appUserRepository;
    }

    private boolean isStaff(String role) {
        return STAFF_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    private boolean isTenantLike(String role) {
        return TENANT_LIKE_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    private String generateShareToken() {
        return UUID.randomUUID().toString().replace("-", "") + UUID.randomUUID().toString().replace("-", "").substring(0, 8);
    }

    private TenantProfile getOrCreateProfile(UUID userId) {
        return profileRepository.findByUserId(userId).orElseGet(() -> {
            TenantProfile p = new TenantProfile();
            p.setUserId(userId);
            return profileRepository.save(p);
        });
    }

    public TenantProfileMeResponse getMyProfile(UUID principalUserId) {
        TenantProfile profile = getOrCreateProfile(principalUserId);
        AppUser user = appUserRepository.findById(principalUserId).orElse(null);
        Double avgRating = reviewRepository.avgRatingByTenantUserId(principalUserId);
        long ratingCount = reviewRepository.countByTenantUserId(principalUserId);
        List<TenantReview> reviews = reviewRepository.findByTenantUserIdOrderByCreatedAtDesc(principalUserId, PageRequest.of(0, 10));
        List<TenantProfileMeResponse.ReviewSummary> summaries = reviews.stream()
                .map(r -> new TenantProfileMeResponse.ReviewSummary(r.getId(), r.getFromAccountId(), r.getRating(), r.getReviewText(), r.getCreatedAt()))
                .toList();
        return new TenantProfileMeResponse(
                principalUserId,
                user != null ? user.getDisplayName() : null,
                profile.getAbout(),
                profile.getPhone(),
                profile.getEmail(),
                profile.getLastKnownAddress(),
                avgRating,
                ratingCount,
                summaries
        );
    }

    @Transactional
    public ExportResponse createExport(UUID principalUserId, String principalRole) {
        if (!isTenantLike(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        getOrCreateProfile(principalUserId);
        String token = generateShareToken();
        Instant expiresAt = Instant.now().plusSeconds(EXPORT_EXPIRY_DAYS * 24L * 3600);
        TenantProfileExport ex = new TenantProfileExport();
        ex.setTenantUserId(principalUserId);
        ex.setShareToken(token);
        ex.setStatus("active");
        ex.setExpiresAt(expiresAt);
        ex = exportRepository.save(ex);
        return new ExportResponse(ex.getId(), token, expiresAt, "/api/v1/tenant-profile/share/" + token);
    }

    @Transactional
    public void revokeExport(UUID principalUserId, String principalRole, UUID exportId) {
        if (!isTenantLike(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        TenantProfileExport ex = exportRepository.findById(exportId)
                .orElseThrow(() -> new ResourceNotFoundException("Export not found"));
        if (!ex.getTenantUserId().equals(principalUserId)) {
            throw new AccessDeniedException("Forbidden");
        }
        ex.setStatus("revoked");
        exportRepository.save(ex);
    }

    public TenantProfileShareResponse viewByShareToken(String shareToken, UUID principalUserId, UUID principalAccountId, String principalRole) {
        TenantProfileExport ex = exportRepository.findByShareToken(shareToken)
                .orElseThrow(() -> new ResourceNotFoundException("Export not found"));
        if (!"active".equals(ex.getStatus())) {
            throw new ConflictException("Export has been revoked");
        }
        if (ex.getExpiresAt().isBefore(Instant.now())) {
            throw new ConflictException("Export has expired");
        }
        UUID tenantUserId = ex.getTenantUserId();
        AppUser user = appUserRepository.findById(tenantUserId).orElse(null);
        String displayName = user != null ? user.getDisplayName() : null;
        Double avgRating = reviewRepository.avgRatingByTenantUserId(tenantUserId);
        long ratingCount = reviewRepository.countByTenantUserId(tenantUserId);

        if (principalUserId.equals(tenantUserId)) {
            TenantProfile profile = profileRepository.findByUserId(tenantUserId).orElse(null);
            List<TenantReview> reviews = reviewRepository.findByTenantUserIdOrderByCreatedAtDesc(tenantUserId, PageRequest.of(0, 20));
            List<TenantProfileShareResponse.ReviewSummary> summaries = reviews.stream()
                    .map(r -> new TenantProfileShareResponse.ReviewSummary(r.getId(), r.getFromAccountId(), r.getRating(), r.getReviewText(), r.getCreatedAt()))
                    .toList();
            return TenantProfileShareResponse.full(tenantUserId, displayName,
                    profile != null ? profile.getAbout() : null,
                    profile != null ? profile.getPhone() : null,
                    profile != null ? profile.getEmail() : null,
                    profile != null ? profile.getLastKnownAddress() : null,
                    avgRating, ratingCount, summaries);
        }

        boolean hasApprovedRequest = requestRepository.findApprovedByExportAndAccount(ex.getId(), principalAccountId).isPresent();
        if (hasApprovedRequest && isStaff(principalRole)) {
            TenantProfile profile = profileRepository.findByUserId(tenantUserId).orElse(null);
            List<TenantReview> reviews = reviewRepository.findByTenantUserIdOrderByCreatedAtDesc(tenantUserId, PageRequest.of(0, 20));
            List<TenantProfileShareResponse.ReviewSummary> summaries = reviews.stream()
                    .map(r -> new TenantProfileShareResponse.ReviewSummary(r.getId(), r.getFromAccountId(), r.getRating(), r.getReviewText(), r.getCreatedAt()))
                    .toList();
            return TenantProfileShareResponse.full(tenantUserId, displayName,
                    profile != null ? profile.getAbout() : null,
                    profile != null ? profile.getPhone() : null,
                    profile != null ? profile.getEmail() : null,
                    profile != null ? profile.getLastKnownAddress() : null,
                    avgRating, ratingCount, summaries);
        }

        return TenantProfileShareResponse.redacted(tenantUserId, displayName, avgRating, ratingCount);
    }

    @Transactional
    public TransferRequestResponse requestReview(String shareToken, UUID principalAccountId, UUID principalUserId, String principalRole) {
        if (!isStaff(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        TenantProfileExport ex = exportRepository.findByShareToken(shareToken)
                .orElseThrow(() -> new ResourceNotFoundException("Export not found"));
        if (!"active".equals(ex.getStatus())) {
            throw new ConflictException("Export has been revoked");
        }
        if (ex.getExpiresAt().isBefore(Instant.now())) {
            throw new ConflictException("Export has expired");
        }
        if (requestRepository.findPendingByExportAndAccount(ex.getId(), principalAccountId).isPresent()) {
            throw new ConflictException("Request already pending for this account");
        }
        TenantTransferRequest req = new TenantTransferRequest();
        req.setExportId(ex.getId());
        req.setRequestingAccountId(principalAccountId);
        req.setRequestingUserId(principalUserId);
        req.setStatus("pending");
        req = requestRepository.save(req);
        return new TransferRequestResponse(req.getId(), req.getExportId(), req.getRequestingAccountId(), req.getRequestingUserId(),
                req.getStatus(), req.getRequestedAt(), req.getDecidedAt(), req.getDecisionByUserId());
    }

    @Transactional
    public TransferRequestResponse approveRequest(UUID requestId, UUID principalUserId, String principalRole) {
        if (!isTenantLike(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        TenantTransferRequest req = requestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Request not found"));
        TenantProfileExport ex = exportRepository.findById(req.getExportId())
                .orElseThrow(() -> new ResourceNotFoundException("Export not found"));
        if (!ex.getTenantUserId().equals(principalUserId)) {
            throw new AccessDeniedException("Forbidden");
        }
        if (!"pending".equals(req.getStatus())) {
            throw new ConflictException("Request is not pending");
        }
        req.setStatus("approved");
        req.setDecidedAt(Instant.now());
        req.setDecisionByUserId(principalUserId);
        req = requestRepository.save(req);
        return new TransferRequestResponse(req.getId(), req.getExportId(), req.getRequestingAccountId(), req.getRequestingUserId(),
                req.getStatus(), req.getRequestedAt(), req.getDecidedAt(), req.getDecisionByUserId());
    }

    @Transactional
    public TransferRequestResponse rejectRequest(UUID requestId, UUID principalUserId, String principalRole) {
        if (!isTenantLike(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        TenantTransferRequest req = requestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Request not found"));
        TenantProfileExport ex = exportRepository.findById(req.getExportId())
                .orElseThrow(() -> new ResourceNotFoundException("Export not found"));
        if (!ex.getTenantUserId().equals(principalUserId)) {
            throw new AccessDeniedException("Forbidden");
        }
        if (!"pending".equals(req.getStatus())) {
            throw new ConflictException("Request is not pending");
        }
        req.setStatus("rejected");
        req.setDecidedAt(Instant.now());
        req.setDecisionByUserId(principalUserId);
        req = requestRepository.save(req);
        return new TransferRequestResponse(req.getId(), req.getExportId(), req.getRequestingAccountId(), req.getRequestingUserId(),
                req.getStatus(), req.getRequestedAt(), req.getDecidedAt(), req.getDecisionByUserId());
    }

    public ImportSummaryResponse importByShareToken(String shareToken, UUID principalAccountId, String principalRole) {
        if (!isStaff(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        TenantProfileExport ex = exportRepository.findByShareToken(shareToken)
                .orElseThrow(() -> new ResourceNotFoundException("Export not found"));
        if (!"active".equals(ex.getStatus())) {
            throw new ConflictException("Export has been revoked");
        }
        if (ex.getExpiresAt().isBefore(Instant.now())) {
            throw new ConflictException("Export has expired");
        }
        TenantTransferRequest approved = requestRepository.findApprovedByExportAndAccount(ex.getId(), principalAccountId)
                .orElseThrow(() -> new ConflictException("No approved request for your account"));
        UUID tenantUserId = ex.getTenantUserId();
        AppUser user = appUserRepository.findById(tenantUserId).orElse(null);
        Double avgRating = reviewRepository.avgRatingByTenantUserId(tenantUserId);
        long ratingCount = reviewRepository.countByTenantUserId(tenantUserId);
        List<TenantReview> reviews = reviewRepository.findByTenantUserIdOrderByCreatedAtDesc(tenantUserId, PageRequest.of(0, 50));
        List<ImportSummaryResponse.ReviewSummary> summaries = reviews.stream()
                .map(r -> new ImportSummaryResponse.ReviewSummary(r.getId(), r.getFromAccountId(), r.getRating(), r.getReviewText(), r.getCreatedAt()))
                .toList();
        return new ImportSummaryResponse(tenantUserId, user != null ? user.getDisplayName() : null, avgRating, ratingCount, summaries);
    }
}
