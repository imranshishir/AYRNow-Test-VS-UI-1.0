package com.ayrnow.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class OnboardingIntegrationTest {

    @Autowired
    MockMvc mockMvc;

    @Autowired
    ObjectMapper objectMapper;

    @Test
    void landlord_createProperty_returnsPropertyAndUnitIds() throws Exception {
        String token = loginAndGetToken("landlord-onboard@example.com", "landlord");

        String body = objectMapper.writeValueAsString(new OnboardingPropertyPayload(
                "Sunshine Apartments",
                "123 Main St",
                java.util.List.of("Unit 101", "Unit 102")));

        mockMvc.perform(post("/v1/onboarding/property")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.propertyId", notNullValue()))
                .andExpect(jsonPath("$.unitIds", notNullValue()))
                .andExpect(jsonPath("$.unitIds").isArray())
                .andExpect(jsonPath("$.unitIds.length()", is(2)));
    }

    @Test
    void tenant_createProperty_returns403() throws Exception {
        String token = loginAndGetToken("tenant-onboard@example.com", "tenant");

        String body = objectMapper.writeValueAsString(new OnboardingPropertyPayload("My Place", null, null));

        mockMvc.perform(post("/v1/onboarding/property")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isForbidden());
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
    record OnboardingPropertyPayload(String name, String address, java.util.List<String> units) {}
}
