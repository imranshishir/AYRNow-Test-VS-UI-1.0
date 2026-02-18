package com.ayrnow.api.dto;

import java.time.LocalDate;

/**
 * Partial update for a lease. Only startDate and endDate are editable; status is managed via POST /end.
 */
public record PatchLeaseRequest(
        LocalDate startDate,
        LocalDate endDate
) {}
