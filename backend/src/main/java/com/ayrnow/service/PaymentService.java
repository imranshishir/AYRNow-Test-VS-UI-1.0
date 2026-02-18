package com.ayrnow.service;

import com.ayrnow.domain.entity.PaymentRecord;
import com.ayrnow.domain.repository.PaymentRecordRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;
import java.util.UUID;

@Service
public class PaymentService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");
    private static final Set<String> TENANT_LIKE_ROLES = Set.of("tenant", "family", "cotenant", "co_tenant");

    private final PaymentRecordRepository paymentRepository;
    private final UnitMemberService unitMemberService;
    private final LeaseTenantService leaseTenantService;

    public PaymentService(PaymentRecordRepository paymentRepository,
                          UnitMemberService unitMemberService,
                          LeaseTenantService leaseTenantService) {
        this.paymentRepository = paymentRepository;
        this.unitMemberService = unitMemberService;
        this.leaseTenantService = leaseTenantService;
    }

    private boolean isStaff(String role) {
        return STAFF_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    @Transactional
    public PaymentRecord create(UUID accountId, UUID unitId, UUID leaseId, long amountCents,
                                UUID createdByUserId, String checkoutSessionId, String paymentIntentId) {
        PaymentRecord p = new PaymentRecord();
        p.setAccountId(accountId);
        p.setUnitId(unitId);
        p.setLeaseId(leaseId);
        p.setAmountCents(amountCents);
        p.setCurrency("USD");
        p.setStatus("created");
        p.setCreatedByUserId(createdByUserId);
        p.setStripeCheckoutSessionId(checkoutSessionId);
        p.setStripePaymentIntentId(paymentIntentId);
        return paymentRepository.save(p);
    }

    @Transactional
    public PaymentRecord updateStatus(UUID accountId, String stripePaymentIntentId, String status) {
        PaymentRecord p = paymentRepository.findByStripePaymentIntentId(stripePaymentIntentId)
                .orElse(paymentRepository.findByStripeCheckoutSessionId(stripePaymentIntentId).orElse(null));
        if (p == null || !p.getAccountId().equals(accountId)) {
            return null;
        }
        p.setStatus(status);
        return paymentRepository.save(p);
    }

    @Transactional
    public PaymentRecord markSucceededBySessionId(String checkoutSessionId) {
        return paymentRepository.findByStripeCheckoutSessionId(checkoutSessionId)
                .map(p -> {
                    p.setStatus("succeeded");
                    return paymentRepository.save(p);
                })
                .orElse(null);
    }

    @Transactional
    public PaymentRecord markSucceededByPaymentIntentId(String paymentIntentId) {
        return paymentRepository.findByStripePaymentIntentId(paymentIntentId)
                .map(p -> {
                    p.setStatus("succeeded");
                    return paymentRepository.save(p);
                })
                .orElse(null);
    }

    @Transactional
    public PaymentRecord markFailedByPaymentIntentId(String paymentIntentId) {
        return paymentRepository.findByStripePaymentIntentId(paymentIntentId)
                .map(p -> {
                    p.setStatus("failed");
                    return paymentRepository.save(p);
                })
                .orElse(null);
    }

    public void requirePaymentAccess(UUID accountId, UUID unitId, UUID leaseId, UUID principalUserId, String principalRole) {
        if (isStaff(principalRole)) return;
        if (!TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            throw new AccessDeniedException("Forbidden");
        }
        if (leaseId != null) {
            if (!leaseTenantService.userBelongsToLease(accountId, leaseId, principalUserId)) {
                throw new AccessDeniedException("Forbidden");
            }
        } else {
            if (!unitMemberService.userBelongsToUnit(accountId, unitId, principalUserId)) {
                throw new AccessDeniedException("Forbidden");
            }
        }
    }

    public Page<PaymentRecord> listHistory(UUID accountId, UUID unitId, UUID leaseId,
                                            int page, int size, UUID principalUserId, String principalRole) {
        if (!isStaff(principalRole) && !TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            throw new AccessDeniedException("Forbidden");
        }
        if (!isStaff(principalRole)) {
            if (unitId != null && leaseId != null) {
                if (!leaseTenantService.userBelongsToLease(accountId, leaseId, principalUserId)) {
                    throw new AccessDeniedException("Forbidden");
                }
            } else if (unitId != null) {
                if (!unitMemberService.userBelongsToUnit(accountId, unitId, principalUserId)) {
                    throw new AccessDeniedException("Forbidden");
                }
            } else if (leaseId != null) {
                if (!leaseTenantService.userBelongsToLease(accountId, leaseId, principalUserId)) {
                    throw new AccessDeniedException("Forbidden");
                }
            }
        }
        return paymentRepository.findByAccountWithFilters(
                accountId, unitId, leaseId,
                PageRequest.of(page, Math.min(size, 100)));
    }
}
