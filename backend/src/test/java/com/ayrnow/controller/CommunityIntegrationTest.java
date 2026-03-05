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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.ayrnow.domain.Property;
import com.ayrnow.domain.Unit;
import com.ayrnow.domain.User;
import com.ayrnow.repository.PropertyRepository;
import com.ayrnow.repository.UnitRepository;
import com.ayrnow.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class CommunityIntegrationTest {

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
    PasswordEncoder passwordEncoder;

    private User landlord;
    private Property property;
    private Unit unit;

    @BeforeEach
    void setUp() {
        String uniqueId = UUID.randomUUID().toString().substring(0, 8);
        landlord = new User();
        landlord.setId(UUID.randomUUID());
        landlord.setEmail("comm-landlord-" + uniqueId + "@example.com");
        landlord.setName("Community Landlord");
        landlord.setRole("landlord");
        landlord.setPasswordHash(passwordEncoder.encode("password123"));
        landlord.setCreatedAt(Instant.now());
        landlord = userRepository.save(landlord);

        property = new Property();
        property.setId(UUID.randomUUID());
        property.setOwnerUserId(landlord.getId());
        property.setName("Test Property");
        property.setAddress("456 Oak St");
        property.setCreatedAt(Instant.now());
        property = propertyRepository.save(property);

        unit = new Unit();
        unit.setId(UUID.randomUUID());
        unit.setPropertyId(property.getId());
        unit.setLabel("Unit A");
        unit.setCreatedAt(Instant.now());
        unit = unitRepository.save(unit);
    }

    @Test
    void landlord_createPost_then_listPosts_returnsPost() throws Exception {
        String token = loginAndGetToken(landlord.getEmail(), "password123");

        String createBody = objectMapper.writeValueAsString(new CreatePostPayload(
                "property", property.getId(), "all", "info", "Announcement", "Building maintenance tomorrow"));

        String createResponse = mockMvc.perform(post("/v1/community/posts")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.postId", notNullValue()))
                .andReturn().getResponse().getContentAsString();

        String postId = objectMapper.readTree(createResponse).get("postId").asText();

        mockMvc.perform(get("/v1/community/posts")
                        .param("filter", "property")
                        .param("propertyId", property.getId().toString())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].id", is(postId)))
                .andExpect(jsonPath("$[0].title", is("Announcement")))
                .andExpect(jsonPath("$[0].body", is("Building maintenance tomorrow")));
    }

    @Test
    void landlord_createGlobalPost_then_listAll_returnsPost() throws Exception {
        String token = loginAndGetToken(landlord.getEmail(), "password123");

        String createBody = objectMapper.writeValueAsString(new CreatePostPayload(
                "global", null, "all", "info", "Global Notice", "This is a global announcement"));

        mockMvc.perform(post("/v1/community/posts")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody))
                .andExpect(status().isCreated());

        mockMvc.perform(get("/v1/community/posts")
                        .param("filter", "all")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[?(@.title=='Global Notice')]").exists());
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
    record CreatePostPayload(String scopeType, UUID scopeId, String audience, String priority, String title, String body) {}
}
