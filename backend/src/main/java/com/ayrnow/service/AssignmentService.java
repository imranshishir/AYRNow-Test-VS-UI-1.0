package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.Contractor;
import com.ayrnow.domain.entity.ContractorAssignment;
import com.ayrnow.domain.entity.MaintenanceTicket;
import com.ayrnow.domain.repository.ContractorAssignmentRepository;
import com.ayrnow.domain.repository.ContractorRepository;
import com.ayrnow.domain.repository.MaintenanceTicketRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class AssignmentService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");

    private final ContractorAssignmentRepository assignmentRepository;
    private final ContractorRepository contractorRepository;
    private final MaintenanceTicketRepository ticketRepository;

    public AssignmentService(ContractorAssignmentRepository assignmentRepository,
                            ContractorRepository contractorRepository,
                            MaintenanceTicketRepository ticketRepository) {
        this.assignmentRepository = assignmentRepository;
        this.contractorRepository = contractorRepository;
        this.ticketRepository = ticketRepository;
    }

    public void requireStaff(String principalRole) {
        if (!STAFF_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            throw new AccessDeniedException("Forbidden");
        }
    }

    public boolean contractorCanViewAssignments(UUID accountId, UUID contractorId, UUID principalUserId, String principalRole) {
        if (STAFF_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) return true;
        if (!"contractor".equalsIgnoreCase(principalRole)) return false;
        List<Contractor> contractors = contractorRepository.findByAccountIdAndLinkedUserId(accountId, principalUserId);
        return contractors.stream().anyMatch(c -> c.getId().equals(contractorId));
    }

    @Transactional
    public ContractorAssignment create(UUID accountId, UUID principalUserId, String principalRole, UUID ticketId, UUID contractorId, String notes) {
        requireStaff(principalRole);
        MaintenanceTicket ticket = ticketRepository.findByAccountIdAndId(accountId, ticketId)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found"));
        if ("closed".equals(ticket.getStatus())) {
            throw new ConflictException("Cannot assign: ticket is closed");
        }
        if (assignmentRepository.findActiveByAccountAndTicket(accountId, ticketId).isPresent()) {
            throw new ConflictException("Ticket already has an assignment");
        }
        contractorRepository.findByAccountIdAndId(accountId, contractorId)
                .orElseThrow(() -> new ResourceNotFoundException("Contractor not found"));
        ContractorAssignment a = new ContractorAssignment();
        a.setAccountId(accountId);
        a.setContractorId(contractorId);
        a.setTicketId(ticketId);
        a.setStatus("assigned");
        a.setNotes(notes);
        ContractorAssignment saved = assignmentRepository.save(a);
        if ("open".equals(ticket.getStatus())) {
            ticket.setStatus("in_progress");
            ticket.setAssignedContractorId(contractorId);
            ticketRepository.save(ticket);
        }
        return saved;
    }

    public List<ContractorAssignment> listByContractor(UUID accountId, UUID contractorId, UUID principalUserId, String principalRole) {
        if (!contractorCanViewAssignments(accountId, contractorId, principalUserId, principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        contractorRepository.findByAccountIdAndId(accountId, contractorId)
                .orElseThrow(() -> new ResourceNotFoundException("Contractor not found"));
        return assignmentRepository.findByAccountIdAndContractorIdOrderByAssignedAtDesc(accountId, contractorId);
    }

    @Transactional
    public ContractorAssignment patch(UUID accountId, UUID assignmentId, UUID principalUserId, String principalRole, String status, String notes) {
        ContractorAssignment a = assignmentRepository.findByAccountIdAndId(accountId, assignmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Assignment not found"));
        if (!STAFF_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")
                && !contractorCanViewAssignments(accountId, a.getContractorId(), principalUserId, principalRole)) {
            throw new AccessDeniedException("Forbidden");
        }
        if (status != null && !status.isBlank()) {
            validateTransition(a.getStatus(), status.toLowerCase());
            a.setStatus(status);
            if ("accepted".equals(status)) {
                a.setAcceptedAt(Instant.now());
            } else if ("completed".equals(status)) {
                a.setCompletedAt(Instant.now());
            }
        }
        if (notes != null) a.setNotes(notes);
        return assignmentRepository.save(a);
    }

    @Transactional
    public ContractorAssignment complete(UUID accountId, UUID assignmentId, UUID principalUserId, String principalRole) {
        return patch(accountId, assignmentId, principalUserId, principalRole, "completed", null);
    }

    public ContractorAssignment getById(UUID accountId, UUID assignmentId) {
        return assignmentRepository.findByAccountIdAndId(accountId, assignmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Assignment not found"));
    }

    public ContractorAssignment findActiveByTicket(UUID accountId, UUID ticketId) {
        return assignmentRepository.findActiveByAccountAndTicket(accountId, ticketId).orElse(null);
    }

    private void validateTransition(String from, String to) {
        Set<String> validFromAssigned = Set.of("accepted", "canceled");
        Set<String> validFromAccepted = Set.of("in_progress", "canceled");
        Set<String> validFromInProgress = Set.of("completed");
        if ("assigned".equals(from) && !validFromAssigned.contains(to)) {
            throw new ConflictException("Invalid transition from assigned to " + to);
        }
        if ("accepted".equals(from) && !validFromAccepted.contains(to)) {
            throw new ConflictException("Invalid transition from accepted to " + to);
        }
        if ("in_progress".equals(from) && !"completed".equals(to)) {
            throw new ConflictException("Invalid transition from in_progress to " + to);
        }
        if (Set.of("completed", "canceled").contains(from)) {
            throw new ConflictException("Cannot change status of " + from + " assignment");
        }
    }
}
