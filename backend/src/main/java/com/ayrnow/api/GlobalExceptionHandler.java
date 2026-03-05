package com.ayrnow.api;

import com.fasterxml.jackson.annotation.JsonInclude;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import jakarta.servlet.http.HttpServletRequest;
import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
class LegacyGlobalExceptionHandler {

        private static final Logger log = LoggerFactory.getLogger(LegacyGlobalExceptionHandler.class);

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record ErrorBody(
            String timestamp,
            int status,
            String error,
            String message,
            String path,
            Map<String, String> fields
    ) {
        static ErrorBody of(int status, String error, String message, String path, Map<String, String> fields) {
            return new ErrorBody(
                    DateTimeFormatter.ISO_INSTANT.format(Instant.now()),
                    status,
                    error,
                    message,
                    path,
                    fields
            );
        }
    }

    private String path(HttpServletRequest req) {
        return req != null ? req.getRequestURI() : null;
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorBody> handleValidation(MethodArgumentNotValidException ex, HttpServletRequest req) {
        Map<String, String> fields = new HashMap<>();
        for (FieldError err : ex.getBindingResult().getFieldErrors()) {
            fields.put(err.getField(), err.getDefaultMessage());
        }
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ErrorBody.of(400, "validation_error", "Validation failed", path(req), fields));
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ErrorBody> handleAuth(AuthenticationException ex, HttpServletRequest req) {
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(ErrorBody.of(401, "unauthorized", ex.getMessage() != null ? ex.getMessage() : "Unauthorized", path(req), null));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorBody> handleForbidden(AccessDeniedException ex, HttpServletRequest req) {
        return ResponseEntity
                .status(HttpStatus.FORBIDDEN)
                .body(ErrorBody.of(403, "forbidden", ex.getMessage() != null ? ex.getMessage() : "Forbidden", path(req), null));
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorBody> handleNotFound(ResourceNotFoundException ex, HttpServletRequest req) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ErrorBody.of(404, "not_found", ex.getMessage() != null ? ex.getMessage() : "Not found", path(req), null));
    }

    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<ErrorBody> handleConflict(ConflictException ex, HttpServletRequest req) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(ErrorBody.of(409, "conflict", ex.getMessage() != null ? ex.getMessage() : "Conflict", path(req), null));
    }

    @ExceptionHandler(IdempotencyHitException.class)
    public ResponseEntity<?> handleIdempotencyHit(IdempotencyHitException ex) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ex.getCachedResponse());
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorBody> handleBadRequest(IllegalArgumentException ex, HttpServletRequest req) {
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ErrorBody.of(400, "bad_request", ex.getMessage() != null ? ex.getMessage() : "Bad request", path(req), null));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorBody> handleGeneric(Exception ex, HttpServletRequest req) {
        log.error("Unhandled exception at {}: {}", req != null ? req.getRequestURI() : "?", ex.getMessage(), ex);
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorBody.of(500, "internal_error", "An unexpected error occurred", path(req), null));
    }
}
