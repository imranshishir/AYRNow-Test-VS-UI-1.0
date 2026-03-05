package com.ayrnow.controller;

import java.time.Instant;
import java.util.UUID;

import static org.hamcrest.Matchers.is;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.ayrnow.domain.Notification;
import com.ayrnow.repository.NotificationRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Ensures notifications API returns JSON with "isRead" field (not "read") for Flutter contract.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class NotificationControllerTest {

    @Autowired
    MockMvc mockMvc;

    @Autowired
    ObjectMapper objectMapper;

    @Autowired
    NotificationRepository notificationRepository;

    @Test
    void notificationsList_returnsJsonWithIsReadKey() throws Exception {
        String token = loginAndGetToken("notif-test@example.com", "tenant");
        UUID userId = getUserIdFromMe(token);

        Notification n = new Notification();
        n.setId(UUID.randomUUID());
        n.setTargetUserId(userId);
        n.setType("announcement");
        n.setTitle("Test");
        n.setBody("Body");
        n.setRead(false);
        n.setCreatedAt(Instant.now());
        notificationRepository.save(n);

        mockMvc.perform(get("/v1/notifications")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].isRead").exists())
                .andExpect(jsonPath("$[0].isRead", is(false)));
    }

    private String loginAndGetToken(String email, String role) throws Exception {
        String body = "{\"email\":\"" + email + "\",\"password\":\"testpass\",\"role\":\"" + role + "\"}";
        ResultActions result = mockMvc.perform(post("/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk());
        String response = result.andReturn().getResponse().getContentAsString();
        JsonNode node = objectMapper.readTree(response);
        return node.get("token").asText();
    }

    private UUID getUserIdFromMe(String token) throws Exception {
        String response = mockMvc.perform(get("/v1/me")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        JsonNode node = objectMapper.readTree(response);
        return UUID.fromString(node.get("id").asText());
    }
}
