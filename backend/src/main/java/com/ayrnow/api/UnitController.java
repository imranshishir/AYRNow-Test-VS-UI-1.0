package com.ayrnow.api;

import com.ayrnow.api.dto.CreateInviteRequest;
import com.ayrnow.api.dto.InviteResponse;
import com.ayrnow.api.dto.PatchUnitRequest;
import com.ayrnow.api.dto.UnitMemberResponse;
import com.ayrnow.api.dto.UnitResponse;
import com.ayrnow.domain.entity.TenantInvite;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.domain.entity.UnitMember;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.TenantInviteService;
import com.ayrnow.service.UnitMemberService;
import com.ayrnow.service.UnitService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/units")
public class UnitController {

    private final UnitService unitService;
    private final UnitMemberService unitMemberService;
    private final TenantInviteService tenantInviteService;

    public UnitController(UnitService unitService, UnitMemberService unitMemberService, TenantInviteService tenantInviteService) {
        this.unitService = unitService;
        this.unitMemberService = unitMemberService;
        this.tenantInviteService = tenantInviteService;
    }

    @GetMapping("/{unitId}")
    public UnitResponse getById(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID unitId) {
        Unit u = unitService.getById(principal.accountId(), unitId);
        return UnitResponse.from(u);
    }

    @PatchMapping("/{unitId}")
    public UnitResponse patch(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID unitId,
            @Valid @RequestBody PatchUnitRequest req) {
        Unit u = unitService.patch(
                principal.accountId(),
                unitId,
                req.unitLabel(),
                req.status()
        );
        return UnitResponse.from(u);
    }

    @DeleteMapping("/{unitId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID unitId) {
        unitService.delete(principal.accountId(), unitId);
    }

    @GetMapping("/{unitId}/members")
    public List<UnitMemberResponse> getMembers(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID unitId) {
        List<UnitMember> members = unitMemberService.getMembers(
                principal.accountId(),
                unitId,
                principal.userId(),
                principal.role()
        );
        return members.stream().map(UnitMemberResponse::from).toList();
    }

    @PostMapping("/{unitId}/invites")
    public ResponseEntity<InviteResponse> createInvite(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID unitId,
            @Valid @RequestBody CreateInviteRequest req) {
        TenantInvite inv = tenantInviteService.create(
                principal.accountId(),
                unitId,
                principal.userId(),
                principal.role(),
                req.contactType(),
                req.contactValue(),
                req.role()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(InviteResponse.from(inv));
    }

    @GetMapping("/{unitId}/invites")
    public Page<InviteResponse> listInvites(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID unitId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<TenantInvite> invites = tenantInviteService.listByUnit(
                principal.accountId(),
                unitId,
                principal.userId(),
                principal.role(),
                page,
                size
        );
        return invites.map(InviteResponse::from);
    }
}

