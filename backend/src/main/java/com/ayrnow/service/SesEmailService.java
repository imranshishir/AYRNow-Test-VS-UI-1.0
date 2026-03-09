package com.ayrnow.service;

import com.ayrnow.config.SesProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.ses.SesClient;
import software.amazon.awssdk.services.ses.model.*;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;

@Service
public class SesEmailService {

    private static final Logger log = LoggerFactory.getLogger(SesEmailService.class);

    private final SesProperties properties;
    private SesClient client;

    public SesEmailService(SesProperties properties) {
        this.properties = properties;
    }

    @PostConstruct
    public void init() {
        if (!properties.isConfigured()) {
            log.info("SES not configured (SES_FROM_EMAIL empty); email sending disabled");
            return;
        }
        try {
            client = SesClient.builder()
                    .region(Region.of(properties.getRegion()))
                    .build();
            log.info("SES client initialized for region {}", properties.getRegion());
        } catch (Exception e) {
            log.warn("SES client init failed: {}", e.getMessage());
            client = null;
        }
    }

    @PreDestroy
    public void destroy() {
        if (client != null) {
            client.close();
        }
    }

    /**
     * Send a single email. Does not log recipient or content. On failure logs only a generic message.
     */
    public boolean sendEmail(String toEmail, String subject, String htmlBody, String textBody) {
        if (!properties.isConfigured() || client == null) {
            log.debug("SES not configured or client null; skipping send");
            return false;
        }
        if (toEmail == null || toEmail.isBlank()) {
            log.warn("sendEmail called with empty recipient");
            return false;
        }
        try {
            String from = (properties.getFromName() != null && !properties.getFromName().isBlank())
                    ? properties.getFromName() + " <" + properties.getFromEmail() + ">"
                    : properties.getFromEmail();
            SendEmailRequest request = SendEmailRequest.builder()
                    .source(from)
                    .destination(Destination.builder().toAddresses(toEmail).build())
                    .message(Message.builder()
                            .subject(Content.builder().data(subject).charset("UTF-8").build())
                            .body(Body.builder()
                                    .html(Content.builder().data(htmlBody != null ? htmlBody : textBody).charset("UTF-8").build())
                                    .build())
                            .build())
                    .build();
            client.sendEmail(request);
            return true;
        } catch (Exception e) {
            log.warn("SES send failed: {}", e.getMessage());
            return false;
        }
    }

    public boolean sendVerificationEmail(String toEmail, String verifyLink) {
        String subject = "Verify your AYRNOW email";
        String html = "<p>Click the link below to verify your email:</p><p><a href=\"" + verifyLink + "\">Verify email</a></p><p>If you didn't create an account, ignore this email.</p>";
        String text = "Verify your email: " + verifyLink + " (If you didn't create an account, ignore this email.)";
        return sendEmail(toEmail, subject, html, text);
    }

    public boolean sendPasswordResetEmail(String toEmail, String resetLink) {
        String subject = "Reset your AYRNOW password";
        String html = "<p>Click the link below to reset your password:</p><p><a href=\"" + resetLink + "\">Reset password</a></p><p>If you didn't request this, ignore this email.</p>";
        String text = "Reset your password: " + resetLink + " (If you didn't request this, ignore this email.)";
        return sendEmail(toEmail, subject, html, text);
    }
}
