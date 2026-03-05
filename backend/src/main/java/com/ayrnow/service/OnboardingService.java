package com.ayrnow.service;

import com.ayrnow.domain.*;
import com.ayrnow.dto.AssignTenantRequest;
import com.ayrnow.dto.OnboardingPropertyRequest;
import com.ayrnow.error.ResourceNotFoundException;
import com.ayrnow.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class OnboardingService {

    private final PropertyRepository propertyRepository;
    private final UnitRepository unitRepository;
    private final UserRepository userRepository;
    private final MembershipRepository membershipRepository;
    private final HouseholdMemberRepository householdMemberRepository;
    private final AccessControlService accessControl;

    public OnboardingService(PropertyRepository propertyRepository, UnitRepository unitRepository,
                             UserRepository userRepository, MembershipRepository membershipRepository,
                             HouseholdMemberRepository householdMemberRepository, AccessControlService accessControl) {
        this.propertyRepository = propertyRepository;
        this.unitRepository = unitRepository;
        this.userRepository = userRepository;
        this.membershipRepository = membershipRepository;
        this.householdMemberRepository = householdMemberRepository;
        this.accessControl = accessControl;
    }

    @Transactional
    public Map<String, Object> createProperty(OnboardingPropertyRequest req, UUID userId, String role) {
        if (!"landlord".equalsIgnoreCase(role)) throw new org.springframework.security.access.AccessDeniedException("Landlord only");

        Property prop = new Property();
        prop.setId(UUID.randomUUID());
        prop.setOwnerUserId(userId);
        prop.setName(req.getName());
        prop.setAddress(req.getAddress());
        prop.setCreatedAt(Instant.now());
        prop = propertyRepository.save(prop);

        List<String> unitIds = new ArrayList<>();
        List<String> labels = req.getUnits() != null ? req.getUnits() : List.of("Unit 1");
        for (String label : labels) {
            Unit u = new Unit();
            u.setId(UUID.randomUUID());
            u.setPropertyId(prop.getId());
            u.setLabel(label);
            u.setCreatedAt(Instant.now());
            u = unitRepository.save(u);
            unitIds.add(u.getId().toString());
        }
        return Map.of("propertyId", prop.getId().toString(), "unitIds", unitIds);
    }

    @Transactional
    public Map<String, String> assignTenant(UUID unitId, AssignTenantRequest req, UUID userId, String role) {
        if (!"landlord".equalsIgnoreCase(role)) throw new org.springframework.security.access.AccessDeniedException("Landlord only");
        accessControl.ensureCanAccessUnit(userId, role, unitId);

        User tenant = userRepository.findByEmail(req.getTenantEmail()).orElseGet(() -> {
            User u = new User();
            u.setId(UUID.randomUUID());
            u.setEmail(req.getTenantEmail());
            u.setName(req.getTenantName() != null ? req.getTenantName() : req.getTenantEmail().split("@")[0]);
            u.setRole("tenant");
            u.setCreatedAt(Instant.now());
            return userRepository.save(u);
        });

        if (membershipRepository.findByUnitIdAndUserId(unitId, tenant.getId()).isPresent()) {
            return Map.of("membershipId", "existing", "tenantId", tenant.getId().toString());
        }

        Membership m = new Membership();
        m.setId(UUID.randomUUID());
        m.setUnitId(unitId);
        m.setUserId(tenant.getId());
        m.setRole("tenant");
        m.setCreatedAt(Instant.now());
        m = membershipRepository.save(m);

        if (householdMemberRepository.findByUnitIdAndEmail(unitId, tenant.getEmail()).isEmpty()) {
            HouseholdMember hm = new HouseholdMember();
            hm.setId(UUID.randomUUID());
            hm.setUnitId(unitId);
            hm.setName(tenant.getName() != null ? tenant.getName() : tenant.getEmail());
            hm.setEmail(tenant.getEmail());
            hm.setRole("primaryTenant");
            hm.setStatus("active");
            hm.setCreatedAt(Instant.now());
            householdMemberRepository.save(hm);
        }
        return Map.of("membershipId", m.getId().toString(), "tenantId", tenant.getId().toString());
    }
}
