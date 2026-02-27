package com.ayrnow.service;

import com.ayrnow.api.ConflictException;
import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.api.dto.TicketResponse;
import com.ayrnow.domain.entity.Contractor;
import com.ayrnow.domain.entity.ContractorAssignment;
import com.ayrnow.domain.entity.MaintenanceTicket;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.domain.repository.ContractorRepository;
import com.ayrnow.domain.repository.MaintenanceTicketRepository;
import com.ayrnow.domain.repository.PropertyRepository;
import com.ayrnow.domain.repository.UnitRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class TicketService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");
    private static final Set<String> TENANT_LIKE_ROLES = Set.of("tenant", "family", "cotenant", "co_tenant");

    private final MaintenanceTicketRepository ticketRepository;
    private final UnitRepository unitRepository;
    private final PropertyRepository propertyRepository;
    private final UnitMemberService unitMemberService;
    private final AssignmentService assignmentService;
    private final ContractorRepository contractorRepository;

    public TicketService(MaintenanceTicketRepository ticketRepository,
                         UnitRepository unitRepository,
                         PropertyRepository propertyRepository,
                         UnitMemberService unitMemberService,
                         AssignmentService assignmentService,
                         ContractorRepository contractorRepository) {
        this.ticketRepository = ticketRepository;
        this.unitRepository = unitRepository;
        this.propertyRepository = propertyRepository;
        this.unitMemberService = unitMemberService;
        this.assignmentService = assignmentService;
        this.contractorRepository = contractorRepository;
    }

    private boolean isStaff(String role) {
        return STAFF_ROLES.contains(role != null ? role.toLowerCase() : "");
    }

    private void requireTicketAccess(UUID accountId, MaintenanceTicket ticket, UUID principalUserId, String principalRole) {
        if (isStaff(principalRole)) return;
        if (TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            if (!unitMemberService.userBelongsToUnit(accountId, ticket.getUnitId(), principalUserId)) {
                throw new AccessDeniedException("Forbidden");
            }
            return;
        }
        throw new AccessDeniedException("Forbidden");
    }

    private void requireUnitAccessForCreate(UUID accountId, UUID unitId, UUID principalUserId, String principalRole) {
        if (isStaff(principalRole)) return;
        if (TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            if (!unitMemberService.userBelongsToUnit(accountId, unitId, principalUserId)) {
                throw new AccessDeniedException("Forbidden");
            }
            return;
        }
        throw new AccessDeniedException("Forbidden");
    }

    public Page<MaintenanceTicket> list(UUID accountId, UUID propertyId, UUID unitId, String status, int page, int size, UUID principalUserId, String principalRole) {
        Page<MaintenanceTicket> tickets = ticketRepository.findByAccountWithFilters(accountId, propertyId, unitId, status, PageRequest.of(page, Math.min(size, 100)));
        if (isStaff(principalRole)) return tickets;
        if (TENANT_LIKE_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            List<MaintenanceTicket> filtered = tickets.getContent().stream()
                    .filter(t -> unitMemberService.userBelongsToUnit(accountId, t.getUnitId(), principalUserId))
                    .toList();
            return new PageImpl<>(filtered, tickets.getPageable(), filtered.size());
        }
        return tickets;
    }

    public MaintenanceTicket getById(UUID accountId, UUID ticketId, UUID principalUserId, String principalRole) {
        MaintenanceTicket t = ticketRepository.findByAccountIdAndId(accountId, ticketId)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found"));
        requireTicketAccess(accountId, t, principalUserId, principalRole);
        return t;
    }

    @Transactional
    public MaintenanceTicket create(UUID accountId, UUID principalUserId, String principalRole,
                                   UUID propertyId, UUID unitId, String title, String description, String priority) {
        requireUnitAccessForCreate(accountId, unitId, principalUserId, principalRole);
        unitRepository.findByAccountIdAndId(accountId, unitId)
                .orElseThrow(() -> new ResourceNotFoundException("Unit not found"));
        propertyRepository.findByAccountIdAndId(accountId, propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found"));
        Unit unit = unitRepository.findByAccountIdAndId(accountId, unitId).orElseThrow();
        if (!unit.getPropertyId().equals(propertyId)) {
            throw new IllegalArgumentException("Unit does not belong to property");
        }
        String resolvedPriority = (priority != null && !priority.isBlank()) ? priority.toLowerCase() : "medium";
        if (!Set.of("low", "medium", "high", "urgent").contains(resolvedPriority)) {
            resolvedPriority = "medium";
        }
        MaintenanceTicket t = new MaintenanceTicket();
        t.setAccountId(accountId);
        t.setPropertyId(propertyId);
        t.setUnitId(unitId);
        t.setCreatedByUserId(principalUserId);
        t.setTitle(title);
        t.setDescription(description);
        t.setStatus("open");
        t.setPriority(resolvedPriority);
        return ticketRepository.save(t);
    }

    @Transactional
    public MaintenanceTicket patch(UUID accountId, UUID ticketId, UUID principalUserId, String principalRole,
                                   String title, String description, String priority, String status, UUID assignedContractorId) {
        MaintenanceTicket t = getById(accountId, ticketId, principalUserId, principalRole);
        if (title != null && !title.isBlank()) t.setTitle(title.trim());
        if (description != null) t.setDescription(description);
        if (priority != null && !priority.isBlank()) {
            if (Set.of("low", "medium", "high", "urgent").contains(priority.toLowerCase())) {
                t.setPriority(priority.toLowerCase());
            }
        }
        if (isStaff(principalRole)) {
            if (status != null && !status.isBlank() && Set.of("open", "in_progress", "closed").contains(status.toLowerCase())) {
                t.setStatus(status.toLowerCase());
            }
            if (assignedContractorId != null) {
                t.setAssignedContractorId(assignedContractorId);
            }
        }
        return ticketRepository.save(t);
    }

    @Transactional
    public MaintenanceTicket assign(UUID accountId, UUID ticketId, UUID principalUserId, String principalRole, UUID contractorId) {
        assignmentService.create(accountId, principalUserId, principalRole, ticketId, contractorId, null);
        return ticketRepository.findByAccountIdAndId(accountId, ticketId).orElseThrow();
    }

    public TicketResponse toResponse(MaintenanceTicket t) {
        ContractorAssignment assignment = assignmentService.findActiveByTicket(t.getAccountId(), t.getId());
        TicketResponse.AssignmentSummary summary = null;
        if (assignment != null) {
            Contractor contractor = contractorRepository.findByAccountIdAndId(t.getAccountId(), assignment.getContractorId()).orElse(null);
            summary = new TicketResponse.AssignmentSummary(
                    assignment.getId(),
                    assignment.getContractorId(),
                    contractor != null ? contractor.getName() : null,
                    assignment.getStatus()
            );
        }
        return TicketResponse.from(t, summary);
    }

    @Transactional
    public MaintenanceTicket close(UUID accountId, UUID ticketId, UUID principalUserId, String principalRole) {
        if (!isStaff(principalRole)) throw new AccessDeniedException("Forbidden");
        MaintenanceTicket t = ticketRepository.findByAccountIdAndId(accountId, ticketId)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found"));
        if ("closed".equals(t.getStatus())) {
            throw new ConflictException("Ticket is already closed");
        }
        t.setStatus("closed");
        return ticketRepository.save(t);
    }

    @Transactional
    public MaintenanceTicket reopen(UUID accountId, UUID ticketId, UUID principalUserId, String principalRole) {
        if (!isStaff(principalRole)) throw new AccessDeniedException("Forbidden");
        MaintenanceTicket t = ticketRepository.findByAccountIdAndId(accountId, ticketId)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found"));
        if (!"closed".equals(t.getStatus())) {
            throw new ConflictException("Can only reopen a closed ticket");
        }
        t.setStatus("open");
        return ticketRepository.save(t);
    }
}
