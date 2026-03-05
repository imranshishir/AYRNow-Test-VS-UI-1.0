package com.ayrnow;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories(basePackages = {
        "com.ayrnow.repository",
        "com.ayrnow.domain.repository"
})
public class AyrnowBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(AyrnowBackendApplication.class, args);
    }
}
