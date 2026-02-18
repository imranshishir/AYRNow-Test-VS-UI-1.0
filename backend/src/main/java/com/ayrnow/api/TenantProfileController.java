package com.ayrnow.api;

import com.ayrnow.api.dto.*;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.TenantTransferService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/tenant-profile")
public class TenantProfileController {

    private final TenantTransferService tenantTransferService;

    public TenantProfileController(TenantTransferService tenantTransferService) {
        this.tenantTransferService = tenantTransferService;
    }

    @GetMapping("/me")
    public TenantProfileMeResponse getMyProfile(@AuthenticationPrincipal DevAuthPrincipal principal) {
        return tenantTransferService.getMyProfile(principal.userId());
    }

    @PostMapping("/me/export")
    public ResponseEntity<ExportResponse> createExport(@AuthenticationPrincipal DevAuthPrincipal principal) {
        ExportResponse r = tenantTransferService.createExport(principal.userId(), principal.role());
        return ResponseEntity.status(HttpStatus.CREATED).body(r);
    }

    @PostMapping("/me/exports/{exportId}/revoke")
    public ResponseEntity<Void> revokeExport(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID exportId) {
        tenantTransferService.revokeExport(principal.userId(), principal.role(), exportId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/share/{shareToken}")
    public TenantProfileShareResponse viewByShareToken(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable String shareToken) {
        return tenantTransferService.viewByShareToken(
                shareToken,
                principal.userId(),
                principal.accountId(),
                principal.role());
    }

    @PostMapping("/share/{shareToken}/request-review")
    public ResponseEntity<TransferRequestResponse> requestReview(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable String shareToken) {
        TransferRequestResponse r = tenantTransferService.requestReview(
                shareToken,
                principal.accountId(),
                principal.userId(),
                principal.role());
        return ResponseEntity.status(HttpStatus.CREATED).body(r);
    }

    @PostMapping("/requests/{requestId}/approve")
    public TransferRequestResponse approveRequest(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID requestId) {
        return tenantTransferService.approveRequest(requestId, principal.userId(), principal.role());
    }

    @PostMapping("/requests/{requestId}/reject")
    public TransferRequestResponse rejectRequest(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID requestId) {
        return tenantTransferService.rejectRequest(requestId, principal.userId(), principal.role());
    }

    @PostMapping("/share/{shareToken}/import")
    public ImportSummaryResponse importByShareToken(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable String shareToken) {
        return tenantTransferService.importByShareToken(shareToken, principal.accountId(), principal.role());
    }
}
