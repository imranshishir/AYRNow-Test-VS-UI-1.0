package com.ayrnow.controller;

import com.ayrnow.domain.HouseholdMember;
import com.ayrnow.domain.Membership;
import com.ayrnow.domain.Property;
import com.ayrnow.domain.Unit;
import com.ayrnow.domain.User;
import com.ayrnow.repository.HouseholdMemberRepository;
import com.ayrnow.repository.MembershipRepository;
import com.ayrnow.repository.PropertyRepository;
import com.ayrnow.repository.UnitRepository;
import com.ayrnow.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.UUID;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class HouseholdIntegrationTest {

    @Autowired
    MockMvc mockMvc;

    @Autowired
    ObjectMapper objectMapper;

    @Autowired
    UserRepository userRepository;

    @Autowired
    PropertyRepository propertyRepository;

    @Autowired
    UnitRepository unitRepository;

    @Autowired
    MembershipRepository membershipRepository;

    @Autowired
    HouseholdMemberRepository householdMemberRepository;

    private User tenant;
    private Property property;
    private Unit unit;
    private Membership membership;
    private HouseholdMember primaryMember;

    @BeforeEach
    void setUp() {
        String uniqueId = UUID.randomUUID().toString().substring(0, 8);
        tenant = new User();
        tenant.setId(UUID.randomUUID());
        tenant.setEmail("household-tenant-" + uniqueId + "@example.com");
        tenant.setName("Primary Tenant");
        tenant.setRole("tenant");
        tenant.setCreatedAt(Instant.now());
        tenant = userRepository.save(tenant);

        property = new Property();
        property.setId(UUID.randomUUID());
        property.setName("Household Property");
        property.setCreatedAt(Instant.now());
        property = propertyRepository.save(property);

        unit = new Unit();
        unit.setId(UUID.randomUUID());
        unit.setPropertyId(property.getId());
        unit.setLabel("Unit B");
        unit.setCreatedAt(Instant.now());
        unit = unitRepository.save(unit);

        membership = new Membership();
        membership.setId(UUID.randomUUID());
        membership.setUnitId(unit.getId());
        membership.setUserId(tenant.getId());
        membership.setRole("tenant");
        membership.setCreatedAt(Instant.now());
        membership = membershipRepository.save(membership);

        primaryMember = new HouseholdMember();
        primaryMember.setId(UUID.randomUUID());
        primaryMember.setUnitId(unit.getId());
        primaryMember.setName("Primary Tenant");
        primaryMember.setEmail(tenant.getEmail());
        primaryMember.setRole("primaryTenant");
        primaryMember.setStatus("active");
        primaryMember.setCreatedAt(Instant.now());
        primaryMember = householdMemberRepository.save(primaryMember);
    }

    @Test
    void tenant_inviteMember_then_listMembers_returnsBoth() throws Exception {
        String token = loginAndGetToken(tenant.getEmail(), "tenant");
        String inviteEmail = "co-tenant-" + UUID.randomUUID().toString().substring(0, 8) + "@example.com";

        String inviteBody = objectMapper.writeValueAsString(new InvitePayload(
                unit.getId(), "Co-tenant", inviteEmail, null, "coTenant"));

        mockMvc.perform(post("/v1/household/members/invite")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(inviteBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.memberId", notNullValue()))
                .andExpect(jsonPath("$.inviteCode", notNullValue()));

        mockMvc.perform(get("/v1/household/members")
                        .param("unitId", unit.getId().toString())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()", greaterThanOrEqualTo(2)))
                .andExpect(jsonPath("$[?(@.role=='coTenant')]").exists())
                .andExpect(jsonPath("$[?(@.role=='primaryTenant')]").exists());
    }

    @Test
    void tenant_listMembers_returnsExistingMembers() throws Exception {
        String token = loginAndGetToken(tenant.getEmail(), "tenant");

        mockMvc.perform(get("/v1/household/members")
                        .param("unitId", unit.getId().toString())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()", greaterThanOrEqualTo(1)))
                .andExpect(jsonPath("$[?(@.role=='primaryTenant')]").exists())
                .andExpect(jsonPath("$[?(@.status=='active')]").exists());
    }

    private String loginAndGetToken(String email, String role) throws Exception {
        String req = objectMapper.writeValueAsString(new LoginPayload(email, role));
        String response = mockMvc.perform(post("/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(req))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(response).get("token").asText();
    }

    record LoginPayload(String email, String role) {}
    record InvitePayload(UUID unitId, String name, String email, String phone, String role) {}
}
