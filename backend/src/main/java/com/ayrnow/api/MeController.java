package com.ayrnow.api;

import com.ayrnow.api.dto.MeResponse;
import com.ayrnow.security.DevAuthPrincipal;
import com.ayrnow.service.MeService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class MeController {

    private final MeService meService;

    public MeController(MeService meService) {
        this.meService = meService;
    }

    @GetMapping("/me")
    public MeResponse me(@AuthenticationPrincipal DevAuthPrincipal principal) {
        return meService.getMe(principal.accountId(), principal.userId(), principal.role());
    }
}
