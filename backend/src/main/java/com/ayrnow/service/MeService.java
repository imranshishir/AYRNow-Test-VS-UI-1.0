package com.ayrnow.service;

import com.ayrnow.api.dto.MeResponse;
import com.ayrnow.domain.entity.AppUser;
import com.ayrnow.domain.repository.AppUserRepository;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class MeService {

    private final AppUserRepository appUserRepository;

    public MeService(AppUserRepository appUserRepository) {
        this.appUserRepository = appUserRepository;
    }

    public MeResponse getMe(UUID accountId, UUID userId, String role) {
        return appUserRepository.findByAccountIdAndId(accountId, userId)
                .map(u -> MeResponse.withUser(accountId, userId, role, u.getEmail(), u.getDisplayName()))
                .orElse(MeResponse.fromPrincipal(accountId, userId, role));
    }
}
