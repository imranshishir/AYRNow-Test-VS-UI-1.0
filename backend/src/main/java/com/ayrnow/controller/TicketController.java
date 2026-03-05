package com.ayrnow.controller;

import com.ayrnow.dto.*;
import com.ayrnow.repository.UserRepository;
import com.ayrnow.service.TicketService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/tickets")
public class TicketController {

    private final TicketService ticketService;
    private final UserRepository userRepository;

    public TicketController(TicketService ticketService, UserRepository userRepository) {
        this.ticketService = ticketService;
        this.userRepository = userRepository;
    }

    @GetMapping
    public List<TicketResponse> list(@RequestParam(required = false) UUID propertyId, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return ticketService.listTickets(propertyId, userId, role);
    }

    @GetMapping("/{id}")
    public TicketDetailResponse get(@PathVariable UUID id, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return ticketService.getTicket(id, userId, role);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public TicketResponse create(@Valid @RequestBody CreateTicketRequest request, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return ticketService.createTicket(request, userId, role);
    }

    @PostMapping("/{id}/comments")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void addComment(@PathVariable UUID id, @Valid @RequestBody AddCommentRequest request, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        ticketService.addComment(id, request, userId, role);
    }

    @PatchMapping("/{id}")
    public TicketResponse updateStatus(@PathVariable UUID id, @Valid @RequestBody UpdateTicketStatusRequest request, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        return ticketService.updateStatus(id, request, userId, role);
    }
}
