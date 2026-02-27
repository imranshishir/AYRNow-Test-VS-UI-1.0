package com.ayrnow.api;

import com.ayrnow.api.dto.ContractorResponse;
import com.ayrnow.api.dto.CreateContractorRequest;
import com.ayrnow.api.dto.PatchContractorRequest;
import com.ayrnow.domain.entity.Contractor;
import com.ayrnow.domain.repository.ContractorRepository;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.AssignmentService;
import com.ayrnow.service.ContractorService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/contractors")
public class ContractorController {

    private final ContractorService contractorService;
    private final AssignmentService assignmentService;
    private final ContractorRepository contractorRepository;

    public ContractorController(ContractorService contractorService, AssignmentService assignmentService, ContractorRepository contractorRepository) {
        this.contractorService = contractorService;
        this.assignmentService = assignmentService;
        this.contractorRepository = contractorRepository;
    }

    @GetMapping
    public com.ayrnow.api.dto.PageResponse<ContractorResponse> list(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String specialty,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<Contractor> contractors = contractorService.list(
                principal.accountId(),
                status,
                specialty,
                page,
                size,
                principal.role()
        );
        return com.ayrnow.api.dto.PageResponse.from(contractors.map(ContractorResponse::from));
    }

    @PostMapping
    public ResponseEntity<ContractorResponse> create(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @Valid @RequestBody CreateContractorRequest req) {
        Contractor c = contractorService.create(
                principal.accountId(),
                principal.role(),
                req.name(),
                req.email(),
                req.phone(),
                req.company(),
                req.specialty(),
                req.status()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(ContractorResponse.from(c));
    }

    @GetMapping("/{contractorId}")
    public ContractorResponse getById(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID contractorId) {
        Contractor c = contractorService.getById(principal.accountId(), contractorId, principal.role());
        return ContractorResponse.from(c);
    }

    @PatchMapping("/{contractorId}")
    public ContractorResponse patch(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID contractorId,
            @Valid @RequestBody PatchContractorRequest req) {
        Contractor c = contractorService.patch(
                principal.accountId(),
                contractorId,
                principal.role(),
                req.name(),
                req.email(),
                req.phone(),
                req.company(),
                req.specialty(),
                req.status(),
                req.linkedUserId()
        );
        return ContractorResponse.from(c);
    }

    @DeleteMapping("/{contractorId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID contractorId) {
        contractorService.delete(principal.accountId(), contractorId, principal.role());
    }

    @GetMapping("/{contractorId}/assignments")
    public List<com.ayrnow.api.dto.AssignmentResponse> getAssignments(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID contractorId) {
        var assignments = assignmentService.listByContractor(
                principal.accountId(),
                contractorId,
                principal.userId(),
                principal.role()
        );
        var contractor = contractorRepository.findByAccountIdAndId(principal.accountId(), contractorId).orElse(null);
        return assignments.stream()
                .map(a -> com.ayrnow.api.dto.AssignmentResponse.from(a, contractor))
                .toList();
    }
}
