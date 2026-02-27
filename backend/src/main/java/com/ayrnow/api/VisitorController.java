package com.ayrnow.api;

import com.ayrnow.api.dto.CreateVisitorRequest;
import com.ayrnow.api.dto.PageResponse;
import com.ayrnow.api.dto.VisitorEntryResponse;
import com.ayrnow.domain.entity.VisitorEntry;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.VisitorEntryService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/visitors")
public class VisitorController {

    private final VisitorEntryService visitorService;

    public VisitorController(VisitorEntryService visitorService) {
        this.visitorService = visitorService;
    }

    @GetMapping
    public PageResponse<VisitorEntryResponse> list(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @RequestParam(required = false) UUID propertyId,
            @RequestParam(required = false) UUID unitId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<VisitorEntry> visitors = visitorService.list(
                principal.accountId(),
                propertyId,
                unitId,
                status,
                page,
                size,
                principal.role()
        );
        return PageResponse.from(visitors.map(VisitorEntryResponse::from));
    }

    @PostMapping
    public ResponseEntity<VisitorEntryResponse> create(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @Valid @RequestBody CreateVisitorRequest req) {
        VisitorEntry v = visitorService.create(
                principal.accountId(),
                principal.userId(),
                principal.role(),
                req.propertyId(),
                req.unitId(),
                req.visitorName(),
                req.visitorPhone(),
                req.purpose()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(VisitorEntryResponse.from(v));
    }

    @PostMapping("/{visitorId}/approve")
    public VisitorEntryResponse approve(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID visitorId) {
        VisitorEntry v = visitorService.approve(
                principal.accountId(),
                visitorId,
                principal.userId(),
                principal.role()
        );
        return VisitorEntryResponse.from(v);
    }

    @PostMapping("/{visitorId}/deny")
    public VisitorEntryResponse deny(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID visitorId) {
        VisitorEntry v = visitorService.deny(
                principal.accountId(),
                visitorId,
                principal.userId(),
                principal.role()
        );
        return VisitorEntryResponse.from(v);
    }
}
