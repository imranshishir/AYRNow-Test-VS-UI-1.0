package com.ayrnow.service;

import com.ayrnow.domain.Membership;
import com.ayrnow.domain.Property;
import com.ayrnow.domain.TransferRequest;
import com.ayrnow.domain.Unit;
import com.ayrnow.domain.User;
import com.ayrnow.dto.CreateTransferRequestRequest;
import com.ayrnow.dto.TenantProfileResponse;
import com.ayrnow.dto.TransferDecisionRequest;
import com.ayrnow.dto.TransferRequestResponse;
import com.ayrnow.error.ResourceNotFoundException;
import com.ayrnow.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class TenantTransferService {

    private final UserRepository userRepository;
    private final TransferRequestRepository transferRepository;
    private final MembershipRepository membershipRepository;
    private final UnitRepository unitRepository;
    private final PropertyRepository propertyRepository;
    private final NotificationService notificationService;

    public TenantTransferService(UserRepository userRepository, TransferRequestRepository transferRepository,
                                 MembershipRepository membershipRepository, UnitRepository unitRepository,
                                 PropertyRepository propertyRepository, NotificationService notificationService) {
        this.userRepository = userRepository;
        this.transferRepository = transferRepository;
        this.membershipRepository = membershipRepository;
        this.unitRepository = unitRepository;
        this.propertyRepository = propertyRepository;
        this.notificationService = notificationService;
    }

    public TenantProfileResponse getMyProfile(UUID userId, String role) {
        if (!"tenant".equalsIgnoreCase(role)) throw new org.springframework.security.access.AccessDeniedException("Tenant only");
        User user = userRepository.findById(userId).orElseThrow(() -> new ResourceNotFoundException("User not found"));

        List<TenantProfileResponse.OccupancyRecordResponse> history = new ArrayList<>();
        String currentAddress = "";
        for (Membership m : membershipRepository.findByUserId(userId)) {
            Unit u = unitRepository.findById(m.getUnitId()).orElse(null);
            if (u != null) {
                Property p = propertyRepository.findById(u.getPropertyId()).orElse(null);
                String propName = p != null ? p.getName() : "Unknown";
                String addr = p != null && p.getAddress() != null ? p.getAddress() : propName;
                if (currentAddress.isEmpty()) currentAddress = addr + ", " + u.getLabel();
                history.add(new TenantProfileResponse.OccupancyRecordResponse(
                        propName, u.getLabel(), m.getCreatedAt(), null, p != null && p.getOwnerUserId() != null ? "Landlord" : null));
            }
        }
        if (currentAddress.isEmpty()) currentAddress = "No current address";

        List<TenantProfileResponse.ProfileDocumentResponse> docs = List.of(
                new TenantProfileResponse.ProfileDocumentResponse("d1", "ID", "ID document", "missing"),
                new TenantProfileResponse.ProfileDocumentResponse("d2", "Lease", "Lease agreement", "missing"));

        return new TenantProfileResponse(
                userId.toString(),
                userId.toString(),
                user.getName() != null ? user.getName() : user.getEmail(),
                "",
                user.getEmail(),
                currentAddress,
                history,
                85,
                List.of(),
                docs,
                user.getCreatedAt());
    }

    public TransferRequestResponse getMyActiveRequest(UUID userId, String role) {
        if (!"tenant".equalsIgnoreCase(role)) throw new org.springframework.security.access.AccessDeniedException("Tenant only");
        return transferRepository.findFirstByTenantUserIdAndStatusOrderByCreatedAtDesc(userId, "pending")
                .map(this::toTransferResponse)
                .orElse(null);
    }

    @Transactional
    public TransferRequestResponse createRequest(CreateTransferRequestRequest req, UUID userId, String role) {
        if (!"tenant".equalsIgnoreCase(role)) throw new org.springframework.security.access.AccessDeniedException("Tenant only");
        User tenant = userRepository.findById(userId).orElseThrow();

        TransferRequest tr = new TransferRequest();
        tr.setId(UUID.randomUUID());
        tr.setTenantUserId(userId);
        tr.setTargetEmailOrCode(req.getTargetEmailOrCode());
        tr.setNote(req.getNote());
        tr.setStatus("pending");
        tr.setCreatedAt(Instant.now());
        tr = transferRepository.save(tr);

        Set<UUID> landlordIds = new HashSet<>();
        for (Membership m : membershipRepository.findByUserId(userId)) {
            Unit u = unitRepository.findById(m.getUnitId()).orElse(null);
            if (u != null) {
                Property p = propertyRepository.findById(u.getPropertyId()).orElse(null);
                if (p != null && p.getOwnerUserId() != null) landlordIds.add(p.getOwnerUserId());
            }
        }
        for (UUID lid : landlordIds) {
            Map<String, String> params = new HashMap<>();
            params.put("targetRole", "landlord");
            notificationService.notifyUser(lid, "transferRequest", "New transfer request",
                    "Tenant " + (tenant.getName() != null ? tenant.getName() : tenant.getEmail()) + " requested profile transfer.", "/L-45", params);
        }
        return toTransferResponse(tr);
    }

    public List<TransferRequestResponse> listForLandlord(String status, UUID userId, String role) {
        if (!"landlord".equalsIgnoreCase(role)) throw new org.springframework.security.access.AccessDeniedException("Landlord only");
        List<TransferRequest> list = transferRepository.findAllByOrderByCreatedAtDesc();
        if (status != null && !status.isBlank()) {
            list = list.stream().filter(t -> status.equalsIgnoreCase(t.getStatus())).collect(Collectors.toList());
        }
        return list.stream().map(this::toTransferResponse).collect(Collectors.toList());
    }

    @Transactional
    public TransferRequestResponse decide(UUID requestId, TransferDecisionRequest req, UUID userId, String role) {
        if (!"landlord".equalsIgnoreCase(role)) throw new org.springframework.security.access.AccessDeniedException("Landlord only");
        TransferRequest tr = transferRepository.findById(requestId).orElseThrow(() -> new ResourceNotFoundException("Request not found"));

        tr.setStatus(req.isAccept() ? "accepted" : "rejected");
        tr.setDecidedAt(Instant.now());
        tr.setLandlordMessage(req.getLandlordMessage());
        tr = transferRepository.save(tr);

        Map<String, String> params = new HashMap<>();
        params.put("targetRole", "tenant");
        notificationService.notifyUser(tr.getTenantUserId(), "transferDecision",
                "Transfer request " + (req.isAccept() ? "accepted" : "rejected"),
                req.getLandlordMessage() != null ? req.getLandlordMessage() : "", "/T-45", params);
        return toTransferResponse(tr);
    }

    private TransferRequestResponse toTransferResponse(TransferRequest tr) {
        User tenant = userRepository.findById(tr.getTenantUserId()).orElse(null);
        String tenantName = tenant != null ? (tenant.getName() != null ? tenant.getName() : tenant.getEmail()) : "Unknown";
        return new TransferRequestResponse(
                tr.getId().toString(),
                tr.getTenantUserId().toString(),
                tenantName,
                tr.getTargetEmailOrCode(),
                tr.getNote(),
                tr.getStatus(),
                tr.getCreatedAt(),
                tr.getDecidedAt(),
                tr.getLandlordMessage());
    }
}
