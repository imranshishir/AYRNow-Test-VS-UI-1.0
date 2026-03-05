package com.ayrnow.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/health")
public class HealthController {

    @Value("${app.version:1.0.0}")
    private String version;

    @Value("${git.commit.id.abbrev:unknown}")
    private String gitSha;

    @GetMapping
    public ResponseEntity<Map<String, String>> healthCheck() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "ok");
        response.put("version", version);
        if (!"unknown".equals(gitSha)) {
            response.put("gitSha", gitSha);
        }
        return ResponseEntity.ok(response);
    }
}
