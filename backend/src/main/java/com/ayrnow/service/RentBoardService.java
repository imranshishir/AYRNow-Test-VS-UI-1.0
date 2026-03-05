package com.ayrnow.service;

import com.ayrnow.domain.Membership;
import com.ayrnow.domain.Unit;
import com.ayrnow.domain.User;
import com.ayrnow.dto.RentBoardItemResponse;
import com.ayrnow.repository.LedgerEntryRepository;
import com.ayrnow.repository.MembershipRepository;
import com.ayrnow.repository.PaymentRepository;
import com.ayrnow.repository.UnitRepository;
import com.ayrnow.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class RentBoardService {

    private static final int DEFAULT_RENT_CENTS = 120000;

    private final UnitRepository unitRepository;
    private final MembershipRepository membershipRepository;
    private final UserRepository userRepository;
    private final LedgerEntryRepository ledgerRepository;
    private final PaymentRepository paymentRepository;

    public RentBoardService(UnitRepository unitRepository, MembershipRepository membershipRepository,
                            UserRepository userRepository, LedgerEntryRepository ledgerRepository,
                            PaymentRepository paymentRepository) {
        this.unitRepository = unitRepository;
        this.membershipRepository = membershipRepository;
        this.userRepository = userRepository;
        this.ledgerRepository = ledgerRepository;
        this.paymentRepository = paymentRepository;
    }

    public List<RentBoardItemResponse> listRentBoard(UUID propertyId, UUID userId, String role, java.util.Set<UUID> accessiblePropertyIds) {
        List<Unit> units;
        if (propertyId != null) {
            if (!accessiblePropertyIds.contains(propertyId)) return List.of();
            units = unitRepository.findByPropertyId(propertyId);
        } else {
            units = unitRepository.findAll().stream()
                    .filter(u -> accessiblePropertyIds.contains(u.getPropertyId()))
                    .collect(Collectors.toList());
        }
        LocalDate today = LocalDate.now();
        LocalDate dueDate = today.with(TemporalAdjusters.firstDayOfMonth());
        Instant monthStart = dueDate.atStartOfDay(ZoneId.systemDefault()).toInstant();

        return units.stream()
                .flatMap(u -> membershipRepository.findByUnitId(u.getId()).stream()
                        .filter(m -> m.getRole() != null && m.getRole().toLowerCase().contains("tenant"))
                        .map(m -> {
                            User tenant = userRepository.findById(m.getUserId()).orElse(null);
                            int chargeCents = ledgerRepository.sumChargesForUnitSince(u.getId(), monthStart);
                            int amountDueCents = chargeCents > 0 ? chargeCents : DEFAULT_RENT_CENTS;
                            boolean paid = paymentRepository.existsSucceededForUnitSince(u.getId(), monthStart);
                            String status = paid ? "paid" : (today.isAfter(dueDate) ? "late" : "due");
                            return new RentBoardItemResponse(
                                    u.getId().toString(),
                                    u.getLabel(),
                                    tenant != null ? (tenant.getName() != null ? tenant.getName() : tenant.getEmail()) : "Unknown",
                                    amountDueCents,
                                    dueDate,
                                    status);
                        }))
                .collect(Collectors.toList());
    }
}
