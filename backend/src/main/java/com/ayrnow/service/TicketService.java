package com.ayrnow.service;

import com.ayrnow.domain.Ticket;
import com.ayrnow.domain.TicketComment;
import com.ayrnow.domain.Unit;
import com.ayrnow.domain.User;
import com.ayrnow.dto.*;
import com.ayrnow.error.ResourceNotFoundException;
import com.ayrnow.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class TicketService {

    private static final List<String> VALID_STATUS_TRANSITIONS = List.of("open", "in_progress", "closed");

    private final TicketRepository ticketRepository;
    private final TicketCommentRepository commentRepository;
    private final UnitRepository unitRepository;
    private final UserRepository userRepository;
    private final AccessControlService accessControlService;
    private final NotificationService notificationService;
    private final PropertyRepository propertyRepository;

    public TicketService(TicketRepository ticketRepository, TicketCommentRepository commentRepository,
                         UnitRepository unitRepository, UserRepository userRepository,
                         AccessControlService accessControlService, NotificationService notificationService,
                         PropertyRepository propertyRepository) {
        this.ticketRepository = ticketRepository;
        this.commentRepository = commentRepository;
        this.unitRepository = unitRepository;
        this.userRepository = userRepository;
        this.accessControlService = accessControlService;
        this.notificationService = notificationService;
        this.propertyRepository = propertyRepository;
    }

    public List<TicketResponse> listTickets(UUID propertyId, UUID userId, String role) {
        Set<UUID> accessiblePropertyIds = accessControlService.getAccessiblePropertyIds(userId, role);
        List<Ticket> tickets;
        if (propertyId != null) {
            if (!accessiblePropertyIds.contains(propertyId)) return List.of();
            tickets = ticketRepository.findByPropertyIdOrderByCreatedAtDesc(propertyId);
            Set<UUID> accessibleUnitIds = accessControlService.getAccessibleUnitIdsForProperty(userId, role, propertyId);
            tickets = tickets.stream().filter(t -> accessibleUnitIds.contains(t.getUnitId())).collect(Collectors.toList());
        } else {
            tickets = ticketRepository.findAll().stream()
                    .filter(t -> accessiblePropertyIds.contains(t.getPropertyId()))
                    .filter(t -> {
                        Set<UUID> unitIds = accessControlService.getAccessibleUnitIdsForProperty(userId, role, t.getPropertyId());
                        return unitIds.contains(t.getUnitId());
                    })
                    .sorted((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()))
                    .collect(Collectors.toList());
        }
        return tickets.stream().map(this::toSummaryResponse).collect(Collectors.toList());
    }

    public TicketDetailResponse getTicket(UUID id, UUID userId, String role) {
        Ticket t = ticketRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Ticket not found"));
        accessControlService.ensureCanAccessProperty(userId, role, t.getPropertyId());
        Set<UUID> unitIds = accessControlService.getAccessibleUnitIdsForProperty(userId, role, t.getPropertyId());
        if (!unitIds.contains(t.getUnitId())) throw new ResourceNotFoundException("Ticket not found");
        String unitLabel = unitRepository.findById(t.getUnitId()).map(Unit::getLabel).orElse("Unknown");
        var comments = commentRepository.findByTicketIdOrderByCreatedAtAsc(id).stream()
                .map(c -> {
                    String authorName = userRepository.findById(c.getAuthorUserId()).map(User::getName).orElse("Unknown");
                    if (authorName == null) authorName = userRepository.findById(c.getAuthorUserId()).map(User::getEmail).orElse("Unknown");
                    return new CommentResponse(c.getId().toString(), c.getBody(), c.getCreatedAt(), authorName);
                })
                .collect(Collectors.toList());
        return new TicketDetailResponse(
                t.getId().toString(),
                unitLabel,
                t.getTitle(),
                normalizePriority(t.getPriority()),
                t.getCreatedAt(),
                normalizeStatus(t.getStatus()),
                t.getDescription(),
                comments);
    }

    @Transactional
    public TicketResponse createTicket(CreateTicketRequest req, UUID userId, String role) {
        accessControlService.ensureCanAccessUnit(userId, role, req.getUnitId());
        accessControlService.ensureCanAccessProperty(userId, role, req.getPropertyId());
        Ticket t = new Ticket();
        t.setId(UUID.randomUUID());
        t.setPropertyId(req.getPropertyId());
        t.setUnitId(req.getUnitId());
        t.setCreatedByUserId(userId);
        t.setTitle(req.getTitle());
        t.setDescription(req.getDescription());
        t.setStatus("open");
        t.setPriority(req.getPriority() != null && !req.getPriority().isBlank() ? req.getPriority().toLowerCase() : "medium");
        t.setCreatedAt(java.time.Instant.now());
        t = ticketRepository.save(t);

        var prop = propertyRepository.findById(req.getPropertyId()).orElse(null);
        if (prop != null && prop.getOwnerUserId() != null && !prop.getOwnerUserId().equals(userId)) {
            Map<String, String> params = new HashMap<>();
            params.put("propertyId", req.getPropertyId().toString());
            params.put("unitId", req.getUnitId().toString());
            params.put("targetRole", "landlord");
            notificationService.notifyUser(prop.getOwnerUserId(), "maintenanceTicket", "New ticket: " + t.getTitle(),
                    req.getTitle(), "/L-30", params);
        }
        return toSummaryResponse(t);
    }

    @Transactional
    public void addComment(UUID ticketId, AddCommentRequest req, UUID userId, String role) {
        Ticket t = ticketRepository.findById(ticketId).orElseThrow(() -> new ResourceNotFoundException("Ticket not found"));
        accessControlService.ensureCanAccessProperty(userId, role, t.getPropertyId());
        TicketComment c = new TicketComment();
        c.setId(UUID.randomUUID());
        c.setTicketId(ticketId);
        c.setAuthorUserId(userId);
        c.setBody(req.getBody());
        c.setCreatedAt(java.time.Instant.now());
        commentRepository.save(c);

        UUID notifyUserId = t.getCreatedByUserId().equals(userId)
                ? (propertyRepository.findById(t.getPropertyId()).map(p -> p.getOwnerUserId()).orElse(null))
                : t.getCreatedByUserId();
        if (notifyUserId != null && !notifyUserId.equals(userId)) {
            Map<String, String> params = new HashMap<>();
            params.put("propertyId", t.getPropertyId().toString());
            params.put("unitId", t.getUnitId().toString());
            notificationService.notifyUser(notifyUserId, "comment", "New comment on ticket",
                    req.getBody(), "/T-20", params);
        }
    }

    @Transactional
    public TicketResponse updateStatus(UUID ticketId, UpdateTicketStatusRequest req, UUID userId, String role) {
        if (!"landlord".equalsIgnoreCase(role)) throw new org.springframework.security.access.AccessDeniedException("Landlord only");
        Ticket t = ticketRepository.findById(ticketId).orElseThrow(() -> new ResourceNotFoundException("Ticket not found"));
        accessControlService.ensureCanAccessProperty(userId, role, t.getPropertyId());
        String newStatus = req.getStatus().toLowerCase();
        String oldStatus = normalizeStatus(t.getStatus());
        if (VALID_STATUS_TRANSITIONS.contains(newStatus)) {
            t.setStatus(newStatus);
            ticketRepository.save(t);
            if (!oldStatus.equals(newStatus) && t.getCreatedByUserId() != null) {
                Map<String, String> params = new HashMap<>();
                params.put("propertyId", t.getPropertyId().toString());
                params.put("unitId", t.getUnitId().toString());
                params.put("targetRole", "tenant");
                notificationService.notifyUser(t.getCreatedByUserId(), "maintenanceTicket",
                        "Ticket status updated to " + newStatus, t.getTitle(), "/T-20", params);
            }
        }
        return toSummaryResponse(t);
    }

    private TicketResponse toSummaryResponse(Ticket t) {
        String unitLabel = unitRepository.findById(t.getUnitId()).map(Unit::getLabel).orElse("Unknown");
        return new TicketResponse(t.getId().toString(), unitLabel, t.getTitle(), normalizePriority(t.getPriority()), t.getCreatedAt(), normalizeStatus(t.getStatus()));
    }

    private String normalizeStatus(String s) {
        if (s == null) return "open";
        return switch (s.toLowerCase()) {
            case "in_progress", "in progress", "approved" -> "in_progress";
            case "closed", "done" -> "closed";
            default -> "open";
        };
    }

    private String normalizePriority(String s) {
        if (s == null || s.isBlank()) return "medium";
        return switch (s.toLowerCase()) {
            case "low" -> "low";
            case "high" -> "high";
            case "urgent" -> "urgent";
            default -> "medium";
        };
    }
}
