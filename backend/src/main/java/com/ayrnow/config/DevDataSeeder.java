package com.ayrnow.config;

import com.ayrnow.domain.*;
import com.ayrnow.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.UUID;

@Component
@Profile("local")
public class DevDataSeeder implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DevDataSeeder.class);

    private final UserRepository userRepository;
    private final PropertyRepository propertyRepository;
    private final UnitRepository unitRepository;
    private final MembershipRepository membershipRepository;
    private final TicketRepository ticketRepository;
    private final PasswordEncoder passwordEncoder;

    public DevDataSeeder(UserRepository userRepository, PropertyRepository propertyRepository, 
                         UnitRepository unitRepository, MembershipRepository membershipRepository, 
                         TicketRepository ticketRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.propertyRepository = propertyRepository;
        this.unitRepository = unitRepository;
        this.membershipRepository = membershipRepository;
        this.ticketRepository = ticketRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) throws Exception {
        log.info("Running local DevDataSeeder...");
        String defaultPass = passwordEncoder.encode("DemoPass!234");
        String testPass = passwordEncoder.encode("Test12345!");

        // Seed Users
        User landlord1 = ensureUser("landlord1@ayrnow.dev", "Demo Landlord 1", "landlord", defaultPass);
        User landlord2 = ensureUser("landlord2@ayrnow.dev", "Demo Landlord 2", "landlord", defaultPass);
        User tenant1 = ensureUser("tenant1@ayrnow.dev", "Demo Tenant 1", "tenant", defaultPass);
        User tenant2 = ensureUser("tenant2@ayrnow.dev", "Demo Tenant 2", "tenant", defaultPass);
        User contractor1 = ensureUser("contractor1@ayrnow.dev", "Demo Contractor 1", "contractor", defaultPass);
        User security1 = ensureUser("security1@ayrnow.dev", "Demo Security 1", "security_guard", defaultPass);

        // Targeted test users for local end-to-end flows.
        User testTenant = ensureUser("test.tenant@ayrnow.dev", "Test Tenant", "tenant", testPass);
        User testLandlord = ensureUser("test.landlord@ayrnow.dev", "Test Landlord", "landlord", testPass);

        log.info("Demo users seeded successfully. Test users: {}, {}",
                testTenant.getEmail(), testLandlord.getEmail());
    }

    private User ensureUser(String email, String name, String role, String encodedPassword) {
        return userRepository.findByEmail(email).map(user -> {
            boolean updated = false;
            // update hash if we wanted to enforce it, but let's keep it simple
            if (user.getPasswordHash() == null) {
                user.setPasswordHash(encodedPassword);
                updated = true;
            }
            if (updated) {
                return userRepository.save(user);
            }
            return user;
        }).orElseGet(() -> {
            User u = new User();
            u.setId(UUID.randomUUID());
            u.setEmail(email);
            u.setName(name);
            u.setRole(role);
            u.setPasswordHash(encodedPassword);
            u.setCreatedAt(Instant.now());
            return userRepository.save(u);
        });
    }
}
