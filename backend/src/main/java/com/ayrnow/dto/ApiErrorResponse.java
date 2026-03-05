package com.ayrnow.dto;

public record ApiErrorResponse(String error, String message, String traceId) {}
