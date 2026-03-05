package com.ayrnow.domain.repository;

import com.ayrnow.domain.entity.TicketComment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TicketCommentRepository extends JpaRepository<TicketComment, UUID> {

    List<TicketComment> findByAccountIdAndTicketIdOrderByCreatedAtAsc(UUID accountId, UUID ticketId);
}
