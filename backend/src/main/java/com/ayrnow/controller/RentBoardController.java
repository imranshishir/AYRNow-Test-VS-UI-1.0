package com.ayrnow.controller;

import com.ayrnow.dto.RentBoardItemResponse;
import com.ayrnow.repository.UserRepository;
import com.ayrnow.service.AccessControlService;
import com.ayrnow.service.RentBoardService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1")
public class RentBoardController {

    private final RentBoardService rentBoardService;
    private final AccessControlService accessControlService;
    private final UserRepository userRepository;

    public RentBoardController(RentBoardService rentBoardService, AccessControlService accessControlService, UserRepository userRepository) {
        this.rentBoardService = rentBoardService;
        this.accessControlService = accessControlService;
        this.userRepository = userRepository;
    }

    @GetMapping("/rent-board")
    public List<RentBoardItemResponse> list(@RequestParam(required = false) UUID propertyId, Authentication auth) {
        UUID userId = UUID.fromString(auth.getName());
        String role = userRepository.findById(userId).map(u -> u.getRole()).orElse("tenant");
        if (propertyId != null) accessControlService.ensureCanAccessProperty(userId, role, propertyId);
        var accessibleIds = accessControlService.getAccessiblePropertyIds(userId, role);
        return rentBoardService.listRentBoard(propertyId, userId, role, accessibleIds);
    }
}
