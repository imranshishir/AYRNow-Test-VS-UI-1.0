package com.ayrnow.api;

import com.ayrnow.api.dto.CreatePropertyRequest;
import com.ayrnow.api.dto.CreateUnitRequest;
import com.ayrnow.domain.entity.Property;
import com.ayrnow.domain.entity.Unit;
import com.ayrnow.domain.repository.PropertyRepository;
import com.ayrnow.domain.repository.UnitRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class PropertyUnitIntegrationTest {

    @Autowired
    MockMvc mockMvc;

    @Autowired
    ObjectMapper objectMapper;

    @Autowired
    PropertyRepository propertyRepository;

    @Autowired
    UnitRepository unitRepository;

    private UUID accountId;
    private Property property;

    @BeforeEach
    void setUp() {
        unitRepository.deleteAll();
        propertyRepository.deleteAll();

        accountId = UUID.randomUUID();

        property = new Property();
        property.setId(UUID.randomUUID());
        property.setAccountId(accountId);
        property.setName("Test Property");
        property.setAddress1("123 Main St");
        property.setCity("Buffalo");
        property.setState("NY");
        property.setPostalCode("14201");
        property = propertyRepository.save(property);
    }

    @Test
    void createUnit_happyPath_returns201_andPersists() throws Exception {
        CreateUnitRequest body = new CreateUnitRequest("Unit 1A", "vacant");

        mockMvc.perform(post("/api/v1/properties/{propertyId}/units", property.getId())
                        .header("X-Dev-AccountId", accountId.toString())
                        .header("X-Dev-UserId", UUID.randomUUID().toString())
                        .header("X-Dev-Role", "landlord")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.unitLabel").value("Unit 1A"))
                .andExpect(jsonPath("$.propertyId").value(property.getId().toString()))
                .andExpect(jsonPath("$.status").value("vacant"));

        assertThat(unitRepository.findByAccountIdAndPropertyIdOrderByUnitLabel(accountId, property.getId()))
                .extracting(Unit::getUnitLabel)
                .containsExactly("Unit 1A");
    }

    @Test
    void createUnit_validationError_whenLabelBlank() throws Exception {
        CreateUnitRequest body = new CreateUnitRequest("  ", "vacant");

        mockMvc.perform(post("/api/v1/properties/{propertyId}/units", property.getId())
                        .header("X-Dev-AccountId", accountId.toString())
                        .header("X-Dev-UserId", UUID.randomUUID().toString())
                        .header("X-Dev-Role", "landlord")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isBadRequest());
    }
}

