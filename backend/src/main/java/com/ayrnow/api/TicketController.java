package com.ayrnow.api;

import com.ayrnow.api.dto.AddCommentRequest;
import com.ayrnow.api.dto.AssignTicketRequest;
import com.ayrnow.api.dto.CreateTicketRequest;
import com.ayrnow.api.dto.PatchTicketRequest;
import com.ayrnow.api.dto.PageResponse;
import com.ayrnow.api.dto.TicketCommentResponse;
import com.ayrnow.api.dto.TicketResponse;
import com.ayrnow.domain.entity.MaintenanceTicket;
import com.ayrnow.domain.entity.TicketComment;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.TicketCommentService;
import com.ayrnow.service.TicketService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/tickets")
public class TicketController {

    private final TicketService ticketService;
    private final TicketCommentService ticketCommentService;

    public TicketController(TicketService ticketService, TicketCommentService ticketCommentService) {
        this.ticketService = ticketService;
        this.ticketCommentService = ticketCommentService;
    }

    @GetMapping
    public PageResponse<TicketResponse> list(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @RequestParam(required = false) UUID propertyId,
            @RequestParam(required = false) UUID unitId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<MaintenanceTicket> tickets = ticketService.list(
                principal.accountId(),
                propertyId,
                unitId,
                status,
                page,
                size,
                principal.userId(),
                principal.role()
        );
        return PageResponse.from(tickets.map(ticketService::toResponse));
    }

    @PostMapping
    public ResponseEntity<TicketResponse> create(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @Valid @RequestBody CreateTicketRequest req) {
        MaintenanceTicket t = ticketService.create(
                principal.accountId(),
                principal.userId(),
                principal.role(),
                req.propertyId(),
                req.unitId(),
                req.title(),
                req.description(),
                req.priority()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(ticketService.toResponse(t));
    }

    @GetMapping("/{ticketId}")
    public TicketResponse getById(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID ticketId) {
        MaintenanceTicket t = ticketService.getById(
                principal.accountId(),
                ticketId,
                principal.userId(),
                principal.role()
        );
        return ticketService.toResponse(t);
    }

    @PatchMapping("/{ticketId}")
    public TicketResponse patch(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID ticketId,
            @Valid @RequestBody PatchTicketRequest req) {
        MaintenanceTicket t = ticketService.patch(
                principal.accountId(),
                ticketId,
                principal.userId(),
                principal.role(),
                req.title(),
                req.description(),
                req.priority(),
                req.status(),
                req.assignedContractorId()
        );
        return ticketService.toResponse(t);
    }

    @PostMapping("/{ticketId}/comments")
    public ResponseEntity<TicketCommentResponse> addComment(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID ticketId,
            @Valid @RequestBody AddCommentRequest req) {
        TicketComment c = ticketCommentService.addComment(
                principal.accountId(),
                ticketId,
                principal.userId(),
                principal.role(),
                req.body()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(TicketCommentResponse.from(c));
    }

    @GetMapping("/{ticketId}/comments")
    public List<TicketCommentResponse> getComments(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID ticketId) {
        List<TicketComment> comments = ticketCommentService.getComments(
                principal.accountId(),
                ticketId,
                principal.userId(),
                principal.role()
        );
        return comments.stream().map(TicketCommentResponse::from).toList();
    }

    @PostMapping("/{ticketId}/assign")
    public TicketResponse assign(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID ticketId,
            @Valid @RequestBody AssignTicketRequest req) {
        MaintenanceTicket t = ticketService.assign(
                principal.accountId(),
                ticketId,
                principal.userId(),
                principal.role(),
                req.contractorId()
        );
        return ticketService.toResponse(t);
    }

    @PostMapping("/{ticketId}/close")
    public TicketResponse close(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID ticketId) {
        MaintenanceTicket t = ticketService.close(
                principal.accountId(),
                ticketId,
                principal.userId(),
                principal.role()
        );
        return ticketService.toResponse(t);
    }

    @PostMapping("/{ticketId}/reopen")
    public TicketResponse reopen(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID ticketId) {
        MaintenanceTicket t = ticketService.reopen(
                principal.accountId(),
                ticketId,
                principal.userId(),
                principal.role()
        );
        return ticketService.toResponse(t);
    }
}
