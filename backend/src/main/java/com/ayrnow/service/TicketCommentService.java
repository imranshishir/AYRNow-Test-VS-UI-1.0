package com.ayrnow.service;

import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.MaintenanceTicket;
import com.ayrnow.domain.entity.TicketComment;
import com.ayrnow.domain.repository.MaintenanceTicketRepository;
import com.ayrnow.domain.repository.TicketCommentRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class TicketCommentService {

    private final TicketCommentRepository commentRepository;
    private final MaintenanceTicketRepository ticketRepository;
    private final TicketService ticketService;

    public TicketCommentService(TicketCommentRepository commentRepository,
                                MaintenanceTicketRepository ticketRepository,
                                TicketService ticketService) {
        this.commentRepository = commentRepository;
        this.ticketRepository = ticketRepository;
        this.ticketService = ticketService;
    }

    public List<TicketComment> getComments(UUID accountId, UUID ticketId, UUID principalUserId, String principalRole) {
        MaintenanceTicket ticket = ticketService.getById(accountId, ticketId, principalUserId, principalRole);
        return commentRepository.findByAccountIdAndTicketIdOrderByCreatedAtAsc(accountId, ticket.getId());
    }

    @Transactional
    public TicketComment addComment(UUID accountId, UUID ticketId, UUID principalUserId, String principalRole, String body) {
        MaintenanceTicket ticket = ticketService.getById(accountId, ticketId, principalUserId, principalRole);
        TicketComment c = new TicketComment();
        c.setAccountId(accountId);
        c.setTicketId(ticket.getId());
        c.setUserId(principalUserId);
        c.setBody(body);
        return commentRepository.save(c);
    }
}
