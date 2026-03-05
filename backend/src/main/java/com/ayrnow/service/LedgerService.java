package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.api.dto.CreateChargeRequest;
import com.ayrnow.api.dto.CreatePaymentRequest;
import com.ayrnow.api.dto.CreateRefundRequest;
import com.ayrnow.api.dto.CreateAdjustmentRequest;
import com.ayrnow.api.dto.LedgerEntryResponse;
import com.ayrnow.domain.entity.Lease;
import com.ayrnow.domain.entity.LedgerEntry;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.domain.repository.LedgerEntryRepository;
import com.ayrnow.domain.repository.LeaseRepository;
import com.ayrnow.domain.repository.UnitRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Set;
import java.util.UUID;

@Service
public class LedgerService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");
    private static final Set<String> TENANT_LIKE_ROLES = Set.of("tenant", "family", "cotenant", "co_tenant");
    private static final Set<String> VALID_DIRECTIONS = Set.of("debit", "credit");

    private final LedgerEntryRepository ledgerRepository;
    private final UnitRepository unitRepository;
    private final LeaseRepository leaseRepository;
    private final UnitMemberService unitMemberService;
    private final LeaseTenantService leaseTenantService;
    private final IdempotencyService idempotencyService;

    public LedgerService(LedgerEntryRepository ledgerRepository,
                         UnitRepository unitRepository,
                         LeaseRepository leaseRepository,
                         UnitMemberService unitMemberService,
                         LeaseTenantService leaseTenantService,
                         IdempotencyService idempotencyService) {
        this.ledgerRepository = ledgerRepository;
        this.unitRepository = unitRepository;
        this.leaseRepository = leaseRepository;
        this.unitMemberService = unitMemberService;
        this.leaseTenantService = leaseTenantService;
        this.idempotencyService = idempotencyService;
    }

    private boolean isStaff(String role) {
        return STAFF_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    private void requireUnitAccess(UUID accountId, UUID unitId, UUID principalUserId, String principalRole) {
        if (isStaff(principalRole)) return;
        if (TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            if (!unitMemberService.userBelongsToUnit(accountId, unitId, principalUserId)) {
                throw new AccessDeniedException("Forbidden");
            }
            return;
        }
        throw new AccessDeniedException("Forbidden");
    }

    private void requireLeaseAccess(UUID accountId, UUID leaseId, UUID principalUserId, String principalRole) {
        if (isStaff(principalRole)) return;
        if (TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            if (!leaseTenantService.userBelongsToLease(accountId, leaseId, principalUserId)) {
                throw new AccessDeniedException("Forbidden");
            }
            return;
        }
        throw new AccessDeniedException("Forbidden");
    }

    public Page<LedgerEntry> listByUnit(UUID accountId, UUID unitId, LocalDate from, LocalDate to,
                                       int page, int size, UUID principalUserId, String principalRole) {
        requireUnitAccess(accountId, unitId, principalUserId, principalRole);
        unitRepository.findByAccountIdAndId(accountId, unitId)
                .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
        return ledgerRepository.findByAccountAndUnit(accountId, unitId, from, to,
                PageRequest.of(page, Math.min(size, 100)));
    }

    public Page<LedgerEntry> listByLease(UUID accountId, UUID leaseId, LocalDate from, LocalDate to,
                                         int page, int size, UUID principalUserId, String principalRole) {
        Lease lease = leaseRepository.findByAccountIdAndId(accountId, leaseId)
                .orElseThrow(() -> new ResourceNotFoundException("Lease not found"));
        requireLeaseAccess(accountId, leaseId, principalUserId, principalRole);
        return ledgerRepository.findByAccountAndLease(accountId, leaseId, from, to,
                PageRequest.of(page, Math.min(size, 100)));
    }

    @Transactional
    public LedgerEntry createCharge(UUID accountId, UUID principalUserId, String principalRole,
                                   String idempotencyKey, CreateChargeRequest req) {
        if (!isStaff(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        idempotencyService.claimOrThrow(accountId, idempotencyKey, "POST /api/v1/ledger/charges", req, LedgerEntryResponse.class);
        LedgerEntry e = createEntry(accountId, principalUserId, req.unitId(), req.leaseId(),
                "charge", req.subtype(), req.amountCents(), "debit", req.occurredOn(), req.memo());
        idempotencyService.complete(accountId, idempotencyKey, "POST /api/v1/ledger/charges", LedgerEntryResponse.from(e));
        return e;
    }

    @Transactional
    public LedgerEntry createPayment(UUID accountId, UUID principalUserId, String principalRole,
                                    String idempotencyKey, CreatePaymentRequest req) {
        requireUnitOrLeaseAccessForWrite(accountId, req.unitId(), req.leaseId(), principalUserId, principalRole);
        idempotencyService.claimOrThrow(accountId, idempotencyKey, "POST /api/v1/ledger/payments", req, LedgerEntryResponse.class);
        LedgerEntry e = createEntry(accountId, principalUserId, req.unitId(), req.leaseId(),
                "payment", "rent_payment", req.amountCents(), "credit", req.occurredOn(), req.memo());
        idempotencyService.complete(accountId, idempotencyKey, "POST /api/v1/ledger/payments", LedgerEntryResponse.from(e));
        return e;
    }

    @Transactional
    public LedgerEntry createRefund(UUID accountId, UUID principalUserId, String principalRole,
                                    String idempotencyKey, CreateRefundRequest req) {
        if (!isStaff(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        idempotencyService.claimOrThrow(accountId, idempotencyKey, "POST /api/v1/ledger/refunds", req, LedgerEntryResponse.class);
        LedgerEntry e = createEntry(accountId, principalUserId, req.unitId(), req.leaseId(),
                "refund", "refund", req.amountCents(), "credit", req.occurredOn(), req.memo());
        idempotencyService.complete(accountId, idempotencyKey, "POST /api/v1/ledger/refunds", LedgerEntryResponse.from(e));
        return e;
    }

    @Transactional
    public LedgerEntry createAdjustment(UUID accountId, UUID principalUserId, String principalRole,
                                        String idempotencyKey, CreateAdjustmentRequest req) {
        if (!isStaff(principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        String dir = (req.direction() != null ? req.direction() : "").toLowerCase();
        if (!VALID_DIRECTIONS.contains(dir)) {
            throw new ConflictException("Invalid direction: must be debit or credit");
        }
        idempotencyService.claimOrThrow(accountId, idempotencyKey, "POST /api/v1/ledger/adjustments", req, LedgerEntryResponse.class);
        LedgerEntry e = createEntry(accountId, principalUserId, req.unitId(), req.leaseId(),
                "adjustment", req.subtype(), req.amountCents(), dir, req.occurredOn(), req.memo());
        idempotencyService.complete(accountId, idempotencyKey, "POST /api/v1/ledger/adjustments", LedgerEntryResponse.from(e));
        return e;
    }

    private void requireUnitOrLeaseAccessForWrite(UUID accountId, UUID unitId, UUID leaseId,
                                                 UUID principalUserId, String principalRole) {
        if (isStaff(principalRole)) return;
        if (leaseId != null) {
            requireLeaseAccess(accountId, leaseId, principalUserId, principalRole);
        } else {
            requireUnitAccess(accountId, unitId, principalUserId, principalRole);
        }
    }

    private LedgerEntry createEntry(UUID accountId, UUID principalUserId, UUID unitId, UUID leaseId,
                                   String type, String subtype, long amountCents, String direction,
                                   LocalDate occurredOn, String memo) {
        Unit unit = unitRepository.findByAccountIdAndId(accountId, unitId)
                .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
        if (leaseId != null) {
            Lease lease = leaseRepository.findByAccountIdAndId(accountId, leaseId)
                    .orElseThrow(() -> new ResourceNotFoundException("Lease not found"));
            if (!lease.getUnitId().equals(unitId)) {
                throw new ConflictException("Lease does not belong to unit");
            }
        }
        LedgerEntry e = new LedgerEntry();
        e.setAccountId(accountId);
        e.setUnitId(unitId);
        e.setLeaseId(leaseId);
        e.setType(type);
        e.setSubtype(subtype);
        e.setAmountCents(amountCents);
        e.setCurrency("USD");
        e.setDirection(direction);
        e.setOccurredOn(occurredOn);
        e.setMemo(memo != null && !memo.isBlank() ? memo.trim() : null);
        e.setCreatedByUserId(principalUserId);
        return ledgerRepository.save(e);
    }

    /**
     * Create ledger payment from Stripe webhook. Bypasses role check; uses idempotency from stripe event id.
     */
    @Transactional
    public LedgerEntry createPaymentFromWebhook(UUID accountId, UUID createdByUserId,
                                                UUID unitId, UUID leaseId, long amountCents,
                                                LocalDate occurredOn, String memo,
                                                String stripeEventId, String paymentIntentId) {
        String idempotencyKey = (paymentIntentId != null && !paymentIntentId.isBlank())
                ? "stripe:pi:" + paymentIntentId
                : "stripe:evt:" + stripeEventId;
        String endpoint = "stripe_webhook_payment";
        StripeWebhookPayload payload = new StripeWebhookPayload(accountId, unitId, leaseId, amountCents, paymentIntentId);
        idempotencyService.claimOrThrow(accountId, idempotencyKey, endpoint, payload, LedgerEntryResponse.class);
        LedgerEntry e = createEntry(accountId, createdByUserId, unitId, leaseId,
                "payment", "stripe_payment", amountCents, "credit", occurredOn, memo);
        idempotencyService.complete(accountId, idempotencyKey, endpoint, LedgerEntryResponse.from(e));
        return e;
    }

    /** Payload for idempotency: deterministic per payment (not per event). */
    record StripeWebhookPayload(UUID accountId, UUID unitId, UUID leaseId, long amountCents, String paymentIntentId) {}
}
