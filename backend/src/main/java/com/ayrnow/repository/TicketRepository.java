package com.ayrnow.repository;

import com.ayrnow.domain.Ticket;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TicketRepository extends JpaRepository<Ticket, UUID> {
    List<Ticket> findByPropertyIdOrderByCreatedAtDesc(UUID propertyId);
}
