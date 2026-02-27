package com.ayrnow.api;

import com.ayrnow.api.dto.BalanceResponse;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.BalanceService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/balances")
public class BalanceController {

    private final BalanceService balanceService;

    public BalanceController(BalanceService balanceService) {
        this.balanceService = balanceService;
    }

    @GetMapping("/units/{unitId}")
    public BalanceResponse getUnitBalance(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID unitId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate asOf) {
        return balanceService.getUnitBalance(
                principal.accountId(),
                unitId,
                asOf,
                principal.userId(),
                principal.role()
        );
    }

    @GetMapping("/leases/{leaseId}")
    public BalanceResponse getLeaseBalance(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID leaseId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate asOf) {
        return balanceService.getLeaseBalance(
                principal.accountId(),
                leaseId,
                asOf,
                principal.userId(),
                principal.role()
        );
    }
}
