package com.ayrnow.api;

import com.ayrnow.api.dto.CreateLeaseRequest;
import com.ayrnow.api.dto.EndLeaseRequest;
import com.ayrnow.api.dto.LeaseResponse;
import com.ayrnow.api.dto.LeaseTenantResponse;
import com.ayrnow.api.dto.PatchLeaseRequest;
import com.ayrnow.api.dto.PageResponse;
import com.ayrnow.domain.entity.Lease;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.LeaseService;
import com.ayrnow.service.LeaseTenantService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/leases")
public class LeaseController {

    private final LeaseService leaseService;
    private final LeaseTenantService leaseTenantService;

    public LeaseController(LeaseService leaseService, LeaseTenantService leaseTenantService) {
        this.leaseService = leaseService;
        this.leaseTenantService = leaseTenantService;
    }

    @GetMapping
    public PageResponse<LeaseResponse> list(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) UUID unitId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        var leasePage = leaseService.listByAccount(principal.accountId(), status, unitId, page, size);
        return PageResponse.from(leasePage.map(LeaseResponse::from));
    }

    @GetMapping("/{leaseId}")
    public LeaseResponse getById(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID leaseId) {
        Lease l = leaseService.getById(principal.accountId(), leaseId);
        return LeaseResponse.from(l);
    }

    @GetMapping("/me/active")
    public LeaseResponse getMyActiveLease(@AuthenticationPrincipal DevAuthPrincipal principal) {
        return leaseService.getActiveLeaseForUser(principal.accountId(), principal.userId())
                .map(LeaseResponse::from)
                .orElseThrow(() -> new ResourceNotFoundException("No active lease found"));
    }

    @PostMapping
    public ResponseEntity<LeaseResponse> create(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @Valid @RequestBody CreateLeaseRequest req) {
        Lease l = leaseService.create(
                principal.accountId(),
                req.unitId(),
                req.tenantUserId(),
                req.startDate(),
                req.endDate()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(LeaseResponse.from(l));
    }

    @PatchMapping("/{leaseId}")
    public LeaseResponse patch(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID leaseId,
            @Valid @RequestBody PatchLeaseRequest req) {
        Lease l = leaseService.patch(
                principal.accountId(),
                leaseId,
                req.startDate(),
                req.endDate()
        );
        return LeaseResponse.from(l);
    }

    @PostMapping("/{leaseId}/end")
    public LeaseResponse end(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID leaseId,
            @RequestBody(required = false) EndLeaseRequest req) {
        Lease l = leaseService.end(
                principal.accountId(),
                leaseId,
                req != null ? req.endDate() : null
        );
        return LeaseResponse.from(l);
    }

    @GetMapping("/{leaseId}/tenants")
    public List<LeaseTenantResponse> getTenants(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID leaseId) {
        return leaseTenantService.getTenants(
                principal.accountId(),
                leaseId,
                principal.userId(),
                principal.role()
        );
    }
}
