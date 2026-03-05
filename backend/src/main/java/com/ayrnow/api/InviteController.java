package com.ayrnow.api;

import com.ayrnow.api.dto.InviteResponse;
import com.ayrnow.domain.entity.TenantInvite;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.TenantInviteService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/invites")
public class InviteController {

    private final TenantInviteService tenantInviteService;

    public InviteController(TenantInviteService tenantInviteService) {
        this.tenantInviteService = tenantInviteService;
    }

    @PostMapping("/{inviteId}/resend")
    public InviteResponse resend(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID inviteId) {
        TenantInvite inv = tenantInviteService.resend(
                principal.accountId(),
                inviteId,
                principal.userId(),
                principal.role()
        );
        return InviteResponse.from(inv);
    }

    @PostMapping("/{inviteId}/cancel")
    public InviteResponse cancel(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID inviteId) {
        TenantInvite inv = tenantInviteService.cancel(
                principal.accountId(),
                inviteId,
                principal.userId(),
                principal.role()
        );
        return InviteResponse.from(inv);
    }

    @PostMapping("/accept/{inviteUrlToken}")
    public InviteResponse accept(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable String inviteUrlToken) {
        TenantInvite inv = tenantInviteService.accept(principal.accountId(), principal.userId(), inviteUrlToken);
        return InviteResponse.from(inv);
    }
}
