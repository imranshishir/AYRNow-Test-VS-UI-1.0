package com.ayrnow.api.dto;

import java.time.LocalDate;

/**
 * Optional body for POST /leases/{id}/end. If endDate is omitted, today is used.
 */
public record EndLeaseRequest(LocalDate endDate) {}
