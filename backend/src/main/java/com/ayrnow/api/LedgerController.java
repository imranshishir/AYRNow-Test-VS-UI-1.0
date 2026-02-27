package com.ayrnow.api;

import com.ayrnow.api.dto.*;
import com.ayrnow.domain.entity.LedgerEntry;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.LedgerService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ledger")
public class LedgerController {

    private static final String IDEMPOTENCY_KEY_HEADER = "Idempotency-Key";

    private final LedgerService ledgerService;

    public LedgerController(LedgerService ledgerService) {
        this.ledgerService = ledgerService;
    }

    private String requireIdempotencyKey(HttpServletRequest request) {
        String key = request.getHeader(IDEMPOTENCY_KEY_HEADER);
        if (key == null || key.isBlank()) {
            throw new IllegalArgumentException("Idempotency-Key is required");
        }
        return key.trim();
    }

    @GetMapping("/units/{unitId}")
    public PageResponse<LedgerEntryResponse> listByUnit(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID unitId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<LedgerEntry> entries = ledgerService.listByUnit(
                principal.accountId(),
                unitId,
                from,
                to,
                page,
                size,
                principal.userId(),
                principal.role()
        );
        return PageResponse.from(entries.map(LedgerEntryResponse::from));
    }

    @GetMapping("/leases/{leaseId}")
    public PageResponse<LedgerEntryResponse> listByLease(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID leaseId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<LedgerEntry> entries = ledgerService.listByLease(
                principal.accountId(),
                leaseId,
                from,
                to,
                page,
                size,
                principal.userId(),
                principal.role()
        );
        return PageResponse.from(entries.map(LedgerEntryResponse::from));
    }

    @PostMapping("/charges")
    public ResponseEntity<LedgerEntryResponse> createCharge(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            HttpServletRequest request,
            @Valid @RequestBody CreateChargeRequest req) {
        String idemKey = requireIdempotencyKey(request);
        LedgerEntry e = ledgerService.createCharge(
                principal.accountId(),
                principal.userId(),
                principal.role(),
                idemKey,
                req
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(LedgerEntryResponse.from(e));
    }

    @PostMapping("/payments")
    public ResponseEntity<LedgerEntryResponse> createPayment(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            HttpServletRequest request,
            @Valid @RequestBody CreatePaymentRequest req) {
        String idemKey = requireIdempotencyKey(request);
        LedgerEntry e = ledgerService.createPayment(
                principal.accountId(),
                principal.userId(),
                principal.role(),
                idemKey,
                req
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(LedgerEntryResponse.from(e));
    }

    @PostMapping("/refunds")
    public ResponseEntity<LedgerEntryResponse> createRefund(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            HttpServletRequest request,
            @Valid @RequestBody CreateRefundRequest req) {
        String idemKey = requireIdempotencyKey(request);
        LedgerEntry e = ledgerService.createRefund(
                principal.accountId(),
                principal.userId(),
                principal.role(),
                idemKey,
                req
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(LedgerEntryResponse.from(e));
    }

    @PostMapping("/adjustments")
    public ResponseEntity<LedgerEntryResponse> createAdjustment(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            HttpServletRequest request,
            @Valid @RequestBody CreateAdjustmentRequest req) {
        String idemKey = requireIdempotencyKey(request);
        LedgerEntry e = ledgerService.createAdjustment(
                principal.accountId(),
                principal.userId(),
                principal.role(),
                idemKey,
                req
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(LedgerEntryResponse.from(e));
    }
}
