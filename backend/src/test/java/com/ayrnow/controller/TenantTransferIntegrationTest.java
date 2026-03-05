package com.ayrnow.controller;

import java.time.Instant;
import java.util.UUID;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.ayrnow.domain.Membership;
import com.ayrnow.domain.Property;
import com.ayrnow.domain.Unit;
import com.ayrnow.domain.User;
import com.ayrnow.repository.MembershipRepository;
import com.ayrnow.repository.PropertyRepository;
import com.ayrnow.repository.UnitRepository;
import com.ayrnow.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class TenantTransferIntegrationTest {

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
    PasswordEncoder passwordEncoder;

    private User landlord;
    private User tenant;
    private Property property;
    private Unit unit;
    private Membership membership;

    @BeforeEach
    void setUp() {
        String uniqueId = UUID.randomUUID().toString().substring(0, 8);
        landlord = new User();
        landlord.setId(UUID.randomUUID());
        landlord.setEmail("transfer-landlord-" + uniqueId + "@example.com");
        landlord.setName("Transfer Landlord");
        landlord.setRole("landlord");
        landlord.setPasswordHash(passwordEncoder.encode("password123"));
        landlord.setCreatedAt(Instant.now());
        landlord = userRepository.save(landlord);

        tenant = new User();
        tenant.setId(UUID.randomUUID());
        tenant.setEmail("transfer-tenant-" + uniqueId + "@example.com");
        tenant.setName("Transfer Tenant");
        tenant.setRole("tenant");
        tenant.setPasswordHash(passwordEncoder.encode("password123"));
        tenant.setCreatedAt(Instant.now());
        tenant = userRepository.save(tenant);

        property = new Property();
        property.setId(UUID.randomUUID());
        property.setOwnerUserId(landlord.getId());
        property.setName("Transfer Property");
        property.setCreatedAt(Instant.now());
        property = propertyRepository.save(property);

        unit = new Unit();
        unit.setId(UUID.randomUUID());
        unit.setPropertyId(property.getId());
        unit.setLabel("Unit 1");
        unit.setCreatedAt(Instant.now());
        unit = unitRepository.save(unit);

        membership = new Membership();
        membership.setId(UUID.randomUUID());
        membership.setUnitId(unit.getId());
        membership.setUserId(tenant.getId());
        membership.setRole("tenant");
        membership.setCreatedAt(Instant.now());
        membership = membershipRepository.save(membership);
    }

    @Test
    void tenant_createTransferRequest_landlord_decides_accept() throws Exception {
        String tenantToken = loginAndGetToken(tenant.getEmail(), "password123");
        String landlordToken = loginAndGetToken(landlord.getEmail(), "password123");

        String createBody = objectMapper.writeValueAsString(new CreateTransferPayload("newtenant@example.com", "Moving out"));

        String createResponse = mockMvc.perform(post("/v1/tenant-transfer/requests")
                        .header("Authorization", "Bearer " + tenantToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id", notNullValue()))
                .andExpect(jsonPath("$.status", is("pending")))
                .andReturn().getResponse().getContentAsString();

        String requestId = objectMapper.readTree(createResponse).get("id").asText();

        String decisionBody = objectMapper.writeValueAsString(new DecisionPayload(true, "Approved"));

        mockMvc.perform(post("/v1/tenant-transfer/requests/" + requestId + "/decision")
                        .header("Authorization", "Bearer " + landlordToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(decisionBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("accepted")))
                .andExpect(jsonPath("$.landlordMessage", is("Approved")));
    }

    @Test
    void tenant_createTransferRequest_landlord_decides_reject() throws Exception {
        String tenantToken = loginAndGetToken(tenant.getEmail(), "password123");
        String landlordToken = loginAndGetToken(landlord.getEmail(), "password123");

        String createBody = objectMapper.writeValueAsString(new CreateTransferPayload("other@example.com", null));

        String createResponse = mockMvc.perform(post("/v1/tenant-transfer/requests")
                        .header("Authorization", "Bearer " + tenantToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        String requestId = objectMapper.readTree(createResponse).get("id").asText();

        String decisionBody = objectMapper.writeValueAsString(new DecisionPayload(false, "Not approved"));

        mockMvc.perform(post("/v1/tenant-transfer/requests/" + requestId + "/decision")
                        .header("Authorization", "Bearer " + landlordToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(decisionBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("rejected")));
    }

    private String loginAndGetToken(String email, String password) throws Exception {
        String req = objectMapper.writeValueAsString(new LoginPayload(email, password));
        String response = mockMvc.perform(post("/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(req))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(response).get("token").asText();
    }

    record LoginPayload(String email, String password) {}
    record CreateTransferPayload(String targetEmailOrCode, String note) {}
    record DecisionPayload(boolean accept, String landlordMessage) {}
}
