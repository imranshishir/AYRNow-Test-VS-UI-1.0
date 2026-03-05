package com.ayrnow.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AuthFlowIntegrationTest {

    @Autowired
    MockMvc mockMvc;

    @Autowired
    ObjectMapper objectMapper;

    @Test
    void loginThenMe_authFlow_returnsUserInfo() throws Exception {
        String email = "auth-flow@example.com";
        String role = "landlord";

        String token = loginAndGetToken(email, role);

        mockMvc.perform(get("/v1/me")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email", is(email)))
                .andExpect(jsonPath("$.role", is(role)))
                .andExpect(jsonPath("$.id", notNullValue()));
    }

    @Test
    void me_withoutToken_returns401() throws Exception {
        mockMvc.perform(get("/v1/me"))
                .andExpect(status().is4xxClientError());
    }

    private String loginAndGetToken(String email, String role) throws Exception {
        String body = objectMapper.writeValueAsString(new LoginPayload(email, role));
        ResultActions result = mockMvc.perform(post("/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token", notNullValue()));
        String response = result.andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(response).get("token").asText();
    }

    record LoginPayload(String email, String role) {}
}
