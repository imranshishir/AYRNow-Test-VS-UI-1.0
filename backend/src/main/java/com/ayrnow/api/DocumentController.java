package com.ayrnow.api;

import com.ayrnow.security.DevAuthPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Minimal document v1: lease PDF generation stub + accept.
 * Uses in-memory storage for local/dev. Replace with real storage for production.
 */
@RestController
@RequestMapping("/api/v1/documents")
public class DocumentController {

    private static final Map<UUID, StubDoc> STORAGE = new ConcurrentHashMap<>();

    @PostMapping("/leases/{leaseId}/generate")
    public ResponseEntity<Map<String, Object>> generate(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID leaseId) {
        UUID docId = UUID.randomUUID();
        String downloadUrl = "/api/v1/documents/" + docId + "/download";
        STORAGE.put(docId, new StubDoc(principal.accountId(), leaseId, null, null));
        return ResponseEntity.ok(Map.of(
                "documentId", docId.toString(),
                "downloadUrl", downloadUrl
        ));
    }

    @GetMapping("/{documentId}/download")
    public ResponseEntity<byte[]> download(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID documentId) {
        StubDoc doc = STORAGE.get(documentId);
        if (doc == null || !doc.accountId.equals(principal.accountId())) {
            return ResponseEntity.notFound().build();
        }
        byte[] pdf = generateStubPdfBytes();
        return ResponseEntity.ok()
                .header("Content-Type", "application/pdf")
                .header("Content-Disposition", "attachment; filename=lease-draft.pdf")
                .body(pdf);
    }

    @PostMapping("/{documentId}/accept")
    public ResponseEntity<Map<String, Object>> accept(
            @AuthenticationPrincipal DevAuthPrincipal principal,
            @PathVariable UUID documentId,
            @RequestBody Map<String, Object> body) {
        StubDoc doc = STORAGE.get(documentId);
        if (doc == null || !doc.accountId.equals(principal.accountId())) {
            return ResponseEntity.notFound().build();
        }
        String typedName = (String) body.getOrDefault("typedName", "");
        STORAGE.put(documentId, new StubDoc(doc.accountId, doc.leaseId, principal.userId(), typedName));
        return ResponseEntity.ok(Map.of(
                "documentId", documentId.toString(),
                "accepted", true,
                "acceptedBy", principal.userId().toString(),
                "acceptedAt", java.time.Instant.now().toString()
        ));
    }

    private static byte[] generateStubPdfBytes() {
        String html = "<html><body><h1>Lease Agreement (Stub)</h1><p>Generated document. Add real PDF generation.</p></body></html>";
        return html.getBytes(java.nio.charset.StandardCharsets.UTF_8);
    }

    private record StubDoc(UUID accountId, UUID leaseId, UUID acceptedByUserId, String typedName) {}
}
