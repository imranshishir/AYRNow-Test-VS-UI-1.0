package com.ayrnow.api;

import com.ayrnow.api.dto.CreatePropertyRequest;
import com.ayrnow.api.dto.CreateUnitRequest;
import com.ayrnow.api.dto.PatchPropertyRequest;
import com.ayrnow.api.dto.PatchSecuritySettingsRequest;
import com.ayrnow.api.dto.PropertyResponse;
import com.ayrnow.api.dto.SecuritySettingsResponse;
import com.ayrnow.api.dto.UnitResponse;
import com.ayrnow.domain.entity.Property;
import com.ayrnow.domain.entity.PropertySecuritySettings;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.PropertySecuritySettingsService;
import com.ayrnow.service.PropertyService;
import com.ayrnow.service.UnitService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/properties")
public class PropertyController {

    private final PropertyService propertyService;
    private final UnitService unitService;
    private final PropertySecuritySettingsService securitySettingsService;

    public PropertyController(PropertyService propertyService, UnitService unitService,
                              PropertySecuritySettingsService securitySettingsService) {
        this.propertyService = propertyService;
        this.unitService = unitService;
        this.securitySettingsService = securitySettingsService;
    }

    @GetMapping
    public List<PropertyResponse> list(@AuthenticationPrincipal DevAuthPrincipal principal) {
        return propertyService.listByAccount(principal.accountId())
                .stream()
                .map(PropertyResponse::from)
                .toList();
    }

    @GetMapping("/{propertyId}")
    public PropertyResponse getById(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID propertyId) {
        Property p = propertyService.getById(principal.accountId(), propertyId);
        return PropertyResponse.from(p);
    }

    @PostMapping
    public ResponseEntity<PropertyResponse> create(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @Valid @RequestBody CreatePropertyRequest req) {
        Property p = propertyService.create(
                principal.accountId(),
                req.name(),
                req.address1(),
                req.city(),
                req.state(),
                req.postalCode()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(PropertyResponse.from(p));
    }

    @PatchMapping("/{propertyId}")
    public PropertyResponse patch(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID propertyId,
            @Valid @RequestBody PatchPropertyRequest req) {
        Property p = propertyService.patch(
                principal.accountId(),
                propertyId,
                req.name(),
                req.address1(),
                req.city(),
                req.state(),
                req.postalCode()
        );
        return PropertyResponse.from(p);
    }

    @DeleteMapping("/{propertyId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID propertyId) {
        propertyService.delete(principal.accountId(), propertyId);
    }

    @GetMapping("/{propertyId}/units")
    public List<UnitResponse> listUnits(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID propertyId) {
        if (!unitService.propertyBelongsToAccount(principal.accountId(), propertyId)) {
            throw new ResourceNotFoundException("Property not found");
        }
        return unitService.listByProperty(principal.accountId(), propertyId).stream()
                .map(UnitResponse::from)
                .toList();
    }

    @PostMapping("/{propertyId}/units")
    public ResponseEntity<UnitResponse> createUnit(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID propertyId,
            @Valid @RequestBody CreateUnitRequest req) {
        Unit u = unitService.create(
                principal.accountId(),
                propertyId,
                req.unitLabel(),
                req.status()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(UnitResponse.from(u));
    }

    @GetMapping("/{propertyId}/security-settings")
    public SecuritySettingsResponse getSecuritySettings(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID propertyId) {
        PropertySecuritySettings s = securitySettingsService.get(
                principal.accountId(),
                propertyId,
                principal.role()
        );
        return s != null ? SecuritySettingsResponse.from(s) : SecuritySettingsResponse.defaults(propertyId);
    }

    @PatchMapping("/{propertyId}/security-settings")
    public SecuritySettingsResponse patchSecuritySettings(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID propertyId,
            @RequestBody PatchSecuritySettingsRequest req) {
        PropertySecuritySettings s = securitySettingsService.patch(
                principal.accountId(),
                propertyId,
                principal.role(),
                req != null ? req.approvalRequired() : null
        );
        return SecuritySettingsResponse.from(s);
    }
}
