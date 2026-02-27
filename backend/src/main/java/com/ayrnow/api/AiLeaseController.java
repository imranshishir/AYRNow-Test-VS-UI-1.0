package com.ayrnow.api;

import com.ayrnow.security.DevAuthPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;

/**
 * AI lease draft stub. Returns deterministic draft for local/dev.
 * Implement provider interface for OpenAI later.
 */
@RestController
@RequestMapping("/api/v1/ai")
public class AiLeaseController {

    @PostMapping("/lease-draft")
    public ResponseEntity<Map<String, Object>> generateDraft(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @RequestBody Map<String, Object> body) {
        String propertyId = body.getOrDefault("propertyId", "").toString();
        String unitId = body.getOrDefault("unitId", "").toString();
        String leaseId = body.getOrDefault("leaseId", "").toString();

        String draftText = buildStubDraft(propertyId, unitId, leaseId);

        return ResponseEntity.ok(Map.of(
                "draftText", draftText,
                "sections", java.util.List.of(
                        Map.of("title", "Parties", "content", "Landlord and Tenant agree to the following terms."),
                        Map.of("title", "Premises", "content", "The leased premises is the unit specified in this agreement."),
                        Map.of("title", "Term", "content", "The lease term begins on the start date and continues as specified."),
                        Map.of("title", "Rent", "content", "Rent is due on the first of each month as specified.")
                ),
                "generatedAt", java.time.Instant.now().toString()
        ));
    }

    private static String buildStubDraft(String propertyId, String unitId, String leaseId) {
        return """
            RESIDENTIAL LEASE AGREEMENT (Stub Draft)
            
            This agreement is generated for local development. In production, an AI provider will generate a tailored draft.
            
            Property ID: %s
            Unit ID: %s
            Lease ID: %s
            
            ---
            
            PARTIES: Landlord and Tenant (as identified in the system).
            PREMISES: The residential unit described above.
            TERM: As specified in the lease record.
            RENT: As specified in the lease record.
            
            [End of stub draft]
            """.formatted(propertyId, unitId, leaseId);
    }
}
