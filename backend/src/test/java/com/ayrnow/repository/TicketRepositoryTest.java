package com.ayrnow.repository;

import com.ayrnow.domain.Ticket;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@ActiveProfiles("test")
class TicketRepositoryTest {

    @Autowired
    TicketRepository ticketRepository;

    @Autowired
    TestEntityManager entityManager;

    UUID propertyId;
    UUID unitId;
    UUID userId;

    @BeforeEach
    void setUp() {
        propertyId = UUID.randomUUID();
        unitId = UUID.randomUUID();
        userId = UUID.randomUUID();
    }

    @Test
    void findByPropertyIdOrderByCreatedAtDesc_returnsTicketsInDescOrder() {
        Ticket t1 = new Ticket();
        t1.setId(UUID.randomUUID());
        t1.setPropertyId(propertyId);
        t1.setUnitId(unitId);
        t1.setCreatedByUserId(userId);
        t1.setTitle("First");
        t1.setStatus("Open");
        t1.setPriority("High");
        t1.setCreatedAt(Instant.now().minusSeconds(10));
        ticketRepository.save(t1);

        Ticket t2 = new Ticket();
        t2.setId(UUID.randomUUID());
        t2.setPropertyId(propertyId);
        t2.setUnitId(unitId);
        t2.setCreatedByUserId(userId);
        t2.setTitle("Second");
        t2.setStatus("Open");
        t2.setPriority("Med");
        t2.setCreatedAt(Instant.now());
        ticketRepository.save(t2);

        List<Ticket> found = ticketRepository.findByPropertyIdOrderByCreatedAtDesc(propertyId);
        assertThat(found).hasSize(2);
        assertThat(found.get(0).getTitle()).isEqualTo("Second");
        assertThat(found.get(1).getTitle()).isEqualTo("First");
    }

    @Test
    void findByPropertyId_returnsOnlyMatchingProperty() {
        UUID otherPropertyId = UUID.randomUUID();

        Ticket t = new Ticket();
        t.setId(UUID.randomUUID());
        t.setPropertyId(propertyId);
        t.setUnitId(unitId);
        t.setCreatedByUserId(userId);
        t.setTitle("Match");
        t.setStatus("Open");
        t.setPriority("High");
        t.setCreatedAt(Instant.now());
        ticketRepository.save(t);

        Ticket tOther = new Ticket();
        tOther.setId(UUID.randomUUID());
        tOther.setPropertyId(otherPropertyId);
        tOther.setUnitId(unitId);
        tOther.setCreatedByUserId(userId);
        tOther.setTitle("Other");
        tOther.setStatus("Open");
        tOther.setPriority("Med");
        tOther.setCreatedAt(Instant.now());
        ticketRepository.save(tOther);

        List<Ticket> found = ticketRepository.findByPropertyIdOrderByCreatedAtDesc(propertyId);
        assertThat(found).hasSize(1);
        assertThat(found.get(0).getTitle()).isEqualTo("Match");
    }
}
