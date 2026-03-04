package com.ayrnow.config;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Date;
import java.util.UUID;

@Service
public class JwtService {

    private final JwtProperties properties;
    private final Algorithm algorithm;

    public JwtService(JwtProperties properties) {
        this.properties = properties;
        this.algorithm = Algorithm.HMAC256(properties.getSecret());
    }

    public String createToken(String userId, String email, String role) {
        return JWT.create()
                .withSubject(userId)
                .withClaim("email", email)
                .withClaim("role", role)
                .withExpiresAt(Date.from(Instant.now().plusSeconds(properties.getExpirationMinutes() * 60L)))
                .sign(algorithm);
    }

    public DecodedJWT verify(String token) {
        return JWT.require(algorithm).build().verify(token);
    }

    public String extractUserId(String token) {
        return verify(token).getSubject();
    }

    public String extractRole(String token) {
        var claim = verify(token).getClaim("role");
        return claim != null ? claim.asString() : null;
    }
}
