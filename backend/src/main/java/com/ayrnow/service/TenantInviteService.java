package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.TenantInvite;
import com.ayrnow.domain.entity.UnitMember;
import com.ayrnow.domain.repository.AppUserRepository;
import com.ayrnow.domain.repository.LeaseRepository;
import com.ayrnow.domain.repository.TenantInviteRepository;
import com.ayrnow.domain.repository.UnitMemberRepository;
import com.ayrnow.domain.repository.UnitRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.Set;
import java.util.UUID;

@Service
public class TenantInviteService {

    /** Default invite expiry in days */
    private static final int DEFAULT_EXPIRY_DAIS = 7;

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");

    private final TenantInviteRepository tenantInviteRepository;
    private final UnitRepository unitRepository;
    private final LeaseRepository leaseRepository;
    private final UnitMemberRepository unitMemberRepository;
    private final AppUserRepository appUserRepository;

    private static final SecureRandom RANDOM = new SecureRandom();

    public TenantInviteService(TenantInviteRepository tenantInviteRepository,
                              UnitRepository unitRepository,
                              LeaseRepository leaseRepository,
                              UnitMemberRepository unitMemberRepository,
                              AppUserRepository appUserRepository) {
        this.tenantInviteRepository = tenantInviteRepository;
        this.unitRepository = unitRepository;
        this.leaseRepository = leaseRepository;
        this.unitMemberRepository = unitMemberRepository;
        this.appUserRepository = appUserRepository;
    }

    public void requireStaff(UUID principalUserId, String principalRole) {
        if (!STAFF_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            throw new AccessDeniedException("Forbidden");
        }
    }

    @Transactional
    public TenantInvite create(UUID accountId, UUID unitId, UUID createdByUserId, String principalRole,
                              String contactType, String contactValue, String role) {
        requireStaff(createdByUserId, principalRole);
        unitRepository.findByAccountIdAndId(accountId, unitId)
                .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
        if (!leaseRepository.findActiveByUnitId(unitId).isEmpty()) {
            throw new ConflictException("Cannot create invite: unit has an active lease");
        }
        String invitedRole = (role != null && !role.isBlank()) ? role.toLowerCase() : "tenant";
        if (!Set.of("tenant", "family", "cotenant").contains(invitedRole)) {
            invitedRole = "tenant";
        }
        String inviteCode = generateInviteCode();
        String inviteUrlToken = UUID.randomUUID().toString();
        Instant expiresAt = Instant.now().plusSeconds(DEFAULT_EXPIRY_DAIS * 24L * 3600);
        TenantInvite inv = new TenantInvite();
        inv.setAccountId(accountId);
        inv.setUnitId(unitId);
        inv.setCreatedByUserId(createdByUserId);
        inv.setInviteCode(inviteCode);
        inv.setInviteUrlToken(inviteUrlToken);
        inv.setContactType(contactType);
        inv.setContactValue(contactValue);
        inv.setInvitedRole(invitedRole);
        inv.setStatus("pending");
        inv.setExpiresAt(expiresAt);
        return tenantInviteRepository.save(inv);
    }

    public Page<TenantInvite> listByUnit(UUID accountId, UUID unitId, UUID principalUserId, String principalRole, int page, int size) {
        requireStaff(principalUserId, principalRole);
        unitRepository.findByAccountIdAndId(accountId, unitId)
                .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
        return tenantInviteRepository.findByAccountIdAndUnitIdOrderByCreatedAtDesc(
                accountId, unitId, PageRequest.of(page, Math.min(size, 100)));
    }

    @Transactional
    public TenantInvite resend(UUID accountId, UUID inviteId, UUID principalUserId, String principalRole) {
        requireStaff(principalUserId, principalRole);
        TenantInvite inv = tenantInviteRepository.findByAccountIdAndId(accountId, inviteId)
                .orElseThrow(() -> new ResourceNotFoundException("Invite not found"));
        if (!"pending".equals(inv.getStatus())) {
            throw new ConflictException("Cannot resend: invite is not pending");
        }
        if (inv.getExpiresAt().isBefore(Instant.now())) {
            throw new ConflictException("Cannot resend: invite has expired");
        }
        inv.setLastSentAt(Instant.now());
        return tenantInviteRepository.save(inv);
    }

    @Transactional
    public TenantInvite cancel(UUID accountId, UUID inviteId, UUID principalUserId, String principalRole) {
        requireStaff(principalUserId, principalRole);
        TenantInvite inv = tenantInviteRepository.findByAccountIdAndId(accountId, inviteId)
                .orElseThrow(() -> new ResourceNotFoundException("Invite not found"));
        if ("canceled".equals(inv.getStatus())) {
            return inv;
        }
        if ("accepted".equals(inv.getStatus())) {
            throw new ConflictException("Cannot cancel: invite already accepted");
        }
        inv.setStatus("canceled");
        inv.setCanceledAt(Instant.now());
        return tenantInviteRepository.save(inv);
    }

    @Transactional
    public TenantInvite accept(UUID accountId, UUID principalUserId, String inviteUrlToken) {
        TenantInvite inv = tenantInviteRepository.findByInviteUrlToken(inviteUrlToken)
                .orElseThrow(() -> new ResourceNotFoundException("Invite not found"));
        if (!inv.getAccountId().equals(accountId)) {
            throw new ResourceNotFoundException("Invite not found");
        }
        if (!"pending".equals(inv.getStatus())) {
            throw new ConflictException("Invite is not pending");
        }
        if (inv.getExpiresAt().isBefore(Instant.now())) {
            inv.setStatus("expired");
            tenantInviteRepository.save(inv);
            throw new ConflictException("Invite has expired");
        }
        appUserRepository.findByAccountIdAndId(inv.getAccountId(), principalUserId)
                .orElseThrow(() -> new IllegalArgumentException("User not found in account"));
        if (!unitMemberRepository.existsByAccountIdAndUnitIdAndUserId(inv.getAccountId(), inv.getUnitId(), principalUserId)) {
            UnitMember m = new UnitMember();
            m.setAccountId(inv.getAccountId());
            m.setUnitId(inv.getUnitId());
            m.setUserId(principalUserId);
            m.setRole(inv.getInvitedRole());
            unitMemberRepository.save(m);
        }
        inv.setStatus("accepted");
        inv.setAcceptedByUserId(principalUserId);
        inv.setAcceptedAt(Instant.now());
        return tenantInviteRepository.save(inv);
    }

    private String generateInviteCode() {
        byte[] bytes = new byte[6];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
