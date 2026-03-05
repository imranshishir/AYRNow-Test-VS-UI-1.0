package com.ayrnow.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("AYRNOW API")
                        .version("1.0")
                        .description("REST API for AYRNOW property management")
                        .contact(new Contact()
                                .name("AYRNOW")
                                .email("dev@ayrnow.com")));
    }
}
