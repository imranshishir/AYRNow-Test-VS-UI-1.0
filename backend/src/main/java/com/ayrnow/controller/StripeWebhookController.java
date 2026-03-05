package com.ayrnow.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/webhooks/stripe")
public class StripeWebhookController {

    @PostMapping
    public ResponseEntity<Void> handle() {
        return ResponseEntity.ok().build();
    }
}
