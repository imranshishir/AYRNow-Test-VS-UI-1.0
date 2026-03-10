package com.ayrnow.api;

import com.ayrnow.security.DevAuthPrincipal;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Minimal, in-memory lease packet + tenant document onboarding flow.
 *
 * This controller is intentionally self-contained and uses in-memory storage for
 * dev/test MVP. It can be replaced with a persistent implementation later
 * without changing the Flutter contracts.
 */
@RestController
@RequestMapping("/api/v1/lease-onboarding")
public class LeaseOnboardingController {

    private static final Map<UUID, LeasePacketState> PACKETS = new ConcurrentHashMap<>();
    private static final Map<String, UUID> PACKET_BY_INVITE_TOKEN = new ConcurrentHashMap<>();

    // ---- Landlord: create + update lease packet draft ----

    @PostMapping("/packets")
    public ResponseEntity<LeasePacketResponse> createPacket(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @Valid @RequestBody CreateLeasePacketRequest req
    ) {
        UUID id = UUID.randomUUID();

        LeasePacketState state = new LeasePacketState();
        state.id = id;
        state.accountId = principal.accountId();
        state.unitId = UUID.fromString(req.unitId());
        state.status = "draft";

        // Minimal landlord inputs
        state.tenantName = req.tenantName();
        state.tenantContact = req.tenantContact();
        state.leaseStartDate = req.leaseStartDate();
        state.monthlyRent = req.monthlyRent();
        state.securityDeposit = req.securityDeposit();
        state.leaseTermMonths = req.leaseTermMonths();
        state.utilitiesResponsibility = req.utilitiesResponsibility();
        state.petsAllowed = req.petsAllowed();
        state.specialNotes = req.specialNotes();

        // Suggestions / defaults
        applySuggestions(state);

        // Default required documents
        if (state.documentRequirements == null || state.documentRequirements.isEmpty()) {
            state.documentRequirements = defaultRequirements();
        }

        // Initial invite/onboarding step statuses
        state.inviteStepStatus = new ArrayList<>();
        state.inviteStepStatus.add(new InviteStepStatus("invite_sent", false));
        state.inviteStepStatus.add(new InviteStepStatus("lease_reviewed", false));
        state.inviteStepStatus.add(new InviteStepStatus("lease_accepted", false));
        state.inviteStepStatus.add(new InviteStepStatus("docs_uploaded", false));
        state.inviteStepStatus.add(new InviteStepStatus("submitted_for_review", false));
        state.inviteStepStatus.add(new InviteStepStatus("landlord_reviewed", false));
        state.inviteStepStatus.add(new InviteStepStatus("completed", false));

        PACKETS.put(id, state);
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(state));
    }

    @GetMapping("/packets/{packetId}")
    public LeasePacketResponse getPacket(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID packetId
    ) {
        LeasePacketState state = requirePacket(packetId);
        requireAccount(principal, state);
        return toResponse(state);
    }

    @PatchMapping("/packets/{packetId}")
    public LeasePacketResponse updatePacket(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID packetId,
            @Valid @RequestBody UpdateLeasePacketRequest req
    ) {
        LeasePacketState state = requirePacket(packetId);
        requireAccount(principal, state);
        if ("completed".equalsIgnoreCase(state.status)) {
            throw new IllegalStateException("Cannot modify a completed packet");
        }

        if (req.leaseStartDate() != null) {
            state.leaseStartDate = req.leaseStartDate();
        }
        if (req.monthlyRent() != null) {
            state.monthlyRent = req.monthlyRent();
        }
        if (req.securityDeposit() != null) {
            state.securityDeposit = req.securityDeposit();
        }
        if (req.leaseTermMonths() != null) {
            state.leaseTermMonths = req.leaseTermMonths();
        }
        if (req.utilitiesResponsibility() != null) {
            state.utilitiesResponsibility = req.utilitiesResponsibility();
        }
        if (req.petsAllowed() != null) {
            state.petsAllowed = req.petsAllowed();
        }
        if (req.specialNotes() != null) {
            state.specialNotes = req.specialNotes();
        }
        if (req.leaseEndDate() != null) {
            state.leaseEndDate = req.leaseEndDate();
        }
        if (req.rentDueDay() != null) {
            state.rentDueDay = req.rentDueDay();
        }
        if (req.lateFeeClause() != null) {
            state.lateFeeClause = req.lateFeeClause();
        }
        if (req.documentRequirements() != null && !req.documentRequirements().isEmpty()) {
            state.documentRequirements = new ArrayList<>();
            for (UpdateDocumentRequirementPayload p : req.documentRequirements()) {
                LeasePacketDocumentRequirement d = new LeasePacketDocumentRequirement();
                d.id = p.id() != null && !p.id().isBlank() ? p.id() : UUID.randomUUID().toString();
                d.label = p.label();
                d.required = Boolean.TRUE.equals(p.required());
                d.status = "required";
                d.rejectionReason = null;
                d.filename = null;
                state.documentRequirements.add(d);
            }
        }

        // Re-apply suggestions where values are still null.
        applySuggestions(state);

        if (req.status() != null && !req.status().isBlank()) {
            state.status = req.status();
        }

        return toResponse(state);
    }

    // ---- Landlord: attach invite metadata & mark as sent ----

    @PostMapping("/packets/{packetId}/attach-invite")
    public LeasePacketResponse attachInvite(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID packetId,
            @Valid @RequestBody AttachInviteRequest req
    ) {
        LeasePacketState state = requirePacket(packetId);
        requireAccount(principal, state);

        state.inviteId = req.inviteId();
        state.inviteUrlToken = req.inviteUrlToken();
        state.status = "sent";
        PACKET_BY_INVITE_TOKEN.put(req.inviteUrlToken(), packetId);

        updateStep(state, "invite_sent", true);
        return toResponse(state);
    }

    // ---- Tenant: fetch packet by invite token ----

    @GetMapping("/packets/by-invite/{inviteUrlToken}")
    public LeasePacketResponse getByInvite(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable String inviteUrlToken
    ) {
        UUID packetId = PACKET_BY_INVITE_TOKEN.get(inviteUrlToken);
        if (packetId == null) {
            throw new ResourceNotFoundException("Onboarding packet not found for invite");
        }
        LeasePacketState state = requirePacket(packetId);
        // For MVP, trust invite association; full membership checks can be added later.
        updateStep(state, "viewed", true);
        if ("sent".equalsIgnoreCase(state.status)) {
            state.status = "in_progress";
        }
        return toResponse(state);
    }

    // ---- Tenant: acknowledge lease ----

    @PostMapping("/packets/{packetId}/tenant/acknowledge")
    public LeasePacketResponse acknowledgeLease(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID packetId,
            @Valid @RequestBody AcknowledgeLeaseRequest req
    ) {
        LeasePacketState state = requirePacket(packetId);
        // For MVP we do not strictly verify membership; token access is assumed.
        state.tenantTypedName = req.typedName();
        state.status = "submitted";
        updateStep(state, "lease_reviewed", true);
        updateStep(state, "lease_accepted", true);
        return toResponse(state);
    }

    // ---- Tenant: upload documents (metadata only) ----

    @PostMapping("/packets/{packetId}/tenant/documents/{docId}")
    public LeasePacketResponse uploadDocument(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID packetId,
            @PathVariable String docId,
            @Valid @RequestBody UploadDocumentRequest req
    ) {
        LeasePacketState state = requirePacket(packetId);
        LeasePacketDocumentRequirement doc = state.documentRequirements
                .stream()
                .filter(d -> Objects.equals(d.id, docId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Document requirement not found"));
        doc.status = "uploaded";
        doc.filename = req.filename();
        doc.rejectionReason = null;

        boolean allRequiredUploaded = state.documentRequirements.stream()
                .filter(d -> d.required)
                .allMatch(d -> "uploaded".equalsIgnoreCase(d.status) || "approved".equalsIgnoreCase(d.status));
        if (allRequiredUploaded) {
            updateStep(state, "docs_uploaded", true);
        }
        return toResponse(state);
    }

    // ---- Tenant: submit packet for review ----

    @PostMapping("/packets/{packetId}/tenant/submit")
    public LeasePacketResponse submitForReview(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID packetId
    ) {
        LeasePacketState state = requirePacket(packetId);
        state.status = "under_review";
        updateStep(state, "submitted_for_review", true);
        return toResponse(state);
    }

    // ---- Landlord: review documents and approve/reject ----

    @PostMapping("/packets/{packetId}/review")
    public LeasePacketResponse reviewPacket(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID packetId,
            @Valid @RequestBody ReviewPacketRequest req
    ) {
        LeasePacketState state = requirePacket(packetId);
        requireAccount(principal, state);

        if (req.documentDecisions() != null) {
            for (DocumentDecisionPayload d : req.documentDecisions()) {
                LeasePacketDocumentRequirement doc = state.documentRequirements
                        .stream()
                        .filter(x -> Objects.equals(x.id, d.id()))
                        .findFirst()
                        .orElse(null);
                if (doc == null) continue;
                if (Boolean.TRUE.equals(d.approved())) {
                    doc.status = "approved";
                    doc.rejectionReason = null;
                } else if (Boolean.FALSE.equals(d.approved())) {
                    doc.status = "rejected";
                    doc.rejectionReason = d.reason();
                }
            }
        }

        boolean anyRejected = state.documentRequirements.stream()
                .anyMatch(d -> "rejected".equalsIgnoreCase(d.status));
        if (anyRejected) {
            state.status = "rejected";
        } else if (Boolean.TRUE.equals(req.approved())) {
            state.status = "approved";
            updateStep(state, "landlord_reviewed", true);
            updateStep(state, "completed", true);
        }

        return toResponse(state);
    }

    // ---- Helpers ----

    private static LeasePacketState requirePacket(UUID id) {
        LeasePacketState s = PACKETS.get(id);
        if (s == null) throw new ResourceNotFoundException("Lease packet not found");
        return s;
    }

    private static void requireAccount(DevAuthPrincipal principal, LeasePacketState state) {
        if (!Objects.equals(principal.accountId(), state.accountId)) {
            throw new ResourceNotFoundException("Lease packet not found");
        }
    }

    private static void applySuggestions(LeasePacketState state) {
        if (state.leaseStartDate != null && state.leaseTermMonths != null && state.leaseEndDate == null) {
            state.leaseEndDate = state.leaseStartDate.plusMonths(state.leaseTermMonths);
        }
        if (state.rentDueDay == null && state.leaseStartDate != null) {
            state.rentDueDay = state.leaseStartDate.getDayOfMonth();
        }
        if (state.lateFeeClause == null || state.lateFeeClause.isBlank()) {
            state.lateFeeClause = "Rent is due on day %d of each month. A late fee of 5% of the monthly rent may be charged after a 5-day grace period."
                    .formatted(state.rentDueDay != null ? state.rentDueDay : 1);
        }
        if (state.documentRequirements == null || state.documentRequirements.isEmpty()) {
            state.documentRequirements = defaultRequirements();
        }
    }

    private static List<LeasePacketDocumentRequirement> defaultRequirements() {
        List<LeasePacketDocumentRequirement> docs = new ArrayList<>();

        LeasePacketDocumentRequirement id = new LeasePacketDocumentRequirement();
        id.id = "gov-id";
        id.label = "Government ID";
        id.required = true;
        id.status = "required";
        docs.add(id);

        LeasePacketDocumentRequirement passport = new LeasePacketDocumentRequirement();
        passport.id = "passport";
        passport.label = "Passport (optional alternative)";
        passport.required = false;
        passport.status = "required";
        docs.add(passport);

        LeasePacketDocumentRequirement income = new LeasePacketDocumentRequirement();
        income.id = "proof-income";
        income.label = "Proof of income";
        income.required = true;
        income.status = "required";
        docs.add(income);

        LeasePacketDocumentRequirement other = new LeasePacketDocumentRequirement();
        other.id = "supporting";
        other.label = "Additional supporting document";
        other.required = false;
        other.status = "required";
        docs.add(other);

        return docs;
    }

    private static void updateStep(LeasePacketState state, String code, boolean completed) {
        if (state.inviteStepStatus == null) return;
        for (InviteStepStatus s : state.inviteStepStatus) {
            if (Objects.equals(s.code(), code)) {
                s.completed = completed;
            }
        }
    }

    private static LeasePacketResponse toResponse(LeasePacketState s) {
        List<LeasePacketDocumentRequirementResponse> docs = new ArrayList<>();
        if (s.documentRequirements != null) {
            for (LeasePacketDocumentRequirement d : s.documentRequirements) {
                docs.add(new LeasePacketDocumentRequirementResponse(
                        d.id,
                        d.label,
                        d.required,
                        d.status,
                        d.filename,
                        d.rejectionReason
                ));
            }
        }
        List<InviteStepStatusResponse> steps = new ArrayList<>();
        if (s.inviteStepStatus != null) {
            for (InviteStepStatus st : s.inviteStepStatus) {
                steps.add(new InviteStepStatusResponse(st.code, st.completed));
            }
        }
        return new LeasePacketResponse(
                s.id.toString(),
                s.unitId.toString(),
                s.tenantName,
                s.tenantContact,
                s.leaseStartDate,
                s.leaseEndDate,
                s.monthlyRent,
                s.securityDeposit,
                s.leaseTermMonths,
                s.utilitiesResponsibility,
                s.petsAllowed,
                s.specialNotes,
                s.rentDueDay,
                s.lateFeeClause,
                docs,
                steps,
                s.status,
                s.inviteId,
                s.inviteUrlToken,
                s.tenantTypedName
        );
    }

    // ---- Internal state ----

    private static class LeasePacketState {
        UUID id;
        UUID accountId;
        UUID unitId;

        String tenantName;
        String tenantContact;

        LocalDate leaseStartDate;
        LocalDate leaseEndDate;
        Integer leaseTermMonths;
        BigDecimal monthlyRent;
        BigDecimal securityDeposit;
        String utilitiesResponsibility;
        Boolean petsAllowed;
        String specialNotes;

        Integer rentDueDay;
        String lateFeeClause;

        List<LeasePacketDocumentRequirement> documentRequirements;
        List<InviteStepStatus> inviteStepStatus;

        String status;

        String inviteId;
        String inviteUrlToken;

        String tenantTypedName;
    }

    private static class LeasePacketDocumentRequirement {
        String id;
        String label;
        boolean required;
        String status;
        String filename;
        String rejectionReason;
    }

    private static class InviteStepStatus {
        final String code;
        boolean completed;

        InviteStepStatus(String code, boolean completed) {
            this.code = code;
            this.completed = completed;
        }
    }

    // ---- DTOs (API surface) ----

    public record CreateLeasePacketRequest(
            @NotBlank String unitId,
            @NotBlank String tenantName,
            @NotBlank String tenantContact,
            @NotNull LocalDate leaseStartDate,
            @NotNull @Min(1) Integer leaseTermMonths,
            @NotNull BigDecimal monthlyRent,
            @NotNull BigDecimal securityDeposit,
            @NotBlank String utilitiesResponsibility,
            @NotNull Boolean petsAllowed,
            String specialNotes
    ) {}

    public record UpdateLeasePacketRequest(
            LocalDate leaseStartDate,
            Integer leaseTermMonths,
            BigDecimal monthlyRent,
            BigDecimal securityDeposit,
            String utilitiesResponsibility,
            Boolean petsAllowed,
            String specialNotes,
            LocalDate leaseEndDate,
            Integer rentDueDay,
            String lateFeeClause,
            List<UpdateDocumentRequirementPayload> documentRequirements,
            String status
    ) {}

    public record UpdateDocumentRequirementPayload(
            String id,
            @NotBlank String label,
            Boolean required
    ) {}

    public record AttachInviteRequest(
            @NotBlank String inviteId,
            @NotBlank String inviteUrlToken
    ) {}

    public record AcknowledgeLeaseRequest(
            @NotBlank String typedName
    ) {}

    public record UploadDocumentRequest(
            @NotBlank String filename
    ) {}

    public record ReviewPacketRequest(
            Boolean approved,
            List<DocumentDecisionPayload> documentDecisions
    ) {}

    public record DocumentDecisionPayload(
            @NotBlank String id,
            @NotNull Boolean approved,
            String reason
    ) {}

    public record LeasePacketResponse(
            String id,
            String unitId,
            String tenantName,
            String tenantContact,
            LocalDate leaseStartDate,
            LocalDate leaseEndDate,
            BigDecimal monthlyRent,
            BigDecimal securityDeposit,
            Integer leaseTermMonths,
            String utilitiesResponsibility,
            Boolean petsAllowed,
            String specialNotes,
            Integer rentDueDay,
            String lateFeeClause,
            List<LeasePacketDocumentRequirementResponse> documentRequirements,
            List<InviteStepStatusResponse> inviteSteps,
            String status,
            String inviteId,
            String inviteUrlToken,
            String tenantTypedName
    ) {}

    public record LeasePacketDocumentRequirementResponse(
            String id,
            String label,
            boolean required,
            String status,
            String filename,
            String rejectionReason
    ) {}

    public record InviteStepStatusResponse(
            String code,
            boolean completed
    ) {}
}

