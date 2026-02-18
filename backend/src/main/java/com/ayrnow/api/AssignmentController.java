package com.ayrnow.api;

import com.ayrnow.api.dto.AssignmentResponse;
import com.ayrnow.api.dto.CreateAssignmentRequest;
import com.ayrnow.api.dto.PatchAssignmentRequest;
import com.ayrnow.domain.entity.Contractor;
import com.ayrnow.domain.entity.ContractorAssignment;
import com.ayrnow.domain.repository.ContractorRepository;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.AssignmentService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/assignments")
public class AssignmentController {

    private final AssignmentService assignmentService;
    private final ContractorRepository contractorRepository;

    public AssignmentController(AssignmentService assignmentService, ContractorRepository contractorRepository) {
        this.assignmentService = assignmentService;
        this.contractorRepository = contractorRepository;
    }

    @PostMapping
    public ResponseEntity<AssignmentResponse> create(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @Valid @RequestBody CreateAssignmentRequest req) {
        ContractorAssignment a = assignmentService.create(
                principal.accountId(),
                principal.userId(),
                principal.role(),
                req.ticketId(),
                req.contractorId(),
                req.notes()
        );
        Contractor contractor = contractorRepository.findByAccountIdAndId(principal.accountId(), a.getContractorId()).orElse(null);
        return ResponseEntity.status(HttpStatus.CREATED).body(AssignmentResponse.from(a, contractor));
    }

    @PatchMapping("/{assignmentId}")
    public AssignmentResponse patch(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID assignmentId,
            @Valid @RequestBody PatchAssignmentRequest req) {
        ContractorAssignment a = assignmentService.patch(
                principal.accountId(),
                assignmentId,
                principal.userId(),
                principal.role(),
                req.status(),
                req.notes()
        );
        Contractor contractor = contractorRepository.findByAccountIdAndId(principal.accountId(), a.getContractorId()).orElse(null);
        return AssignmentResponse.from(a, contractor);
    }

    @PostMapping("/{assignmentId}/complete")
    public AssignmentResponse complete(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID assignmentId) {
        ContractorAssignment a = assignmentService.complete(
                principal.accountId(),
                assignmentId,
                principal.userId(),
                principal.role()
        );
        Contractor contractor = contractorRepository.findByAccountIdAndId(principal.accountId(), a.getContractorId()).orElse(null);
        return AssignmentResponse.from(a, contractor);
    }
}
