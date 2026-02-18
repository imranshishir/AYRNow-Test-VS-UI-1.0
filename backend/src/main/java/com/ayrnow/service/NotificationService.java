package com.ayrnow.service;

import com.ayrnow.domain.entity.AppUser;
import com.ayrnow.domain.entity.CommunityPost;
import com.ayrnow.domain.entity.Notification;
import com.ayrnow.domain.repository.AppUserRepository;
import com.ayrnow.domain.repository.NotificationRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final AppUserRepository appUserRepository;

    public NotificationService(NotificationRepository notificationRepository, AppUserRepository appUserRepository) {
        this.notificationRepository = notificationRepository;
        this.appUserRepository = appUserRepository;
    }

    @Transactional
    public void createForNewPost(CommunityPost post) {
        List<AppUser> users = appUserRepository.findByAccountId(post.getAccountId());
        String title = post.getTitle() != null && !post.getTitle().isBlank()
                ? post.getTitle()
                : "New " + post.getKind();
        String body = post.getBody().length() > 200 ? post.getBody().substring(0, 200) + "..." : post.getBody();
        for (AppUser u : users) {
            if (u.getId().equals(post.getAuthorUserId())) continue;
            Notification n = new Notification();
            n.setAccountId(post.getAccountId());
            n.setUserId(u.getId());
            n.setType("post");
            n.setRefId(post.getId());
            n.setTitle(title);
            n.setBody(body);
            notificationRepository.save(n);
        }
    }

    public Page<Notification> list(UUID accountId, UUID userId, int page, int size) {
        return notificationRepository.findByAccountIdAndUserIdOrderByCreatedAtDesc(
                accountId, userId, PageRequest.of(page, Math.min(size, 100)));
    }

    @Transactional
    public void markRead(UUID accountId, UUID userId, List<UUID> notificationIds, boolean all) {
        Instant now = Instant.now();
        if (all) {
            List<Notification> allForUser = notificationRepository.findByAccountIdAndUserIdOrderByCreatedAtDesc(
                    accountId, userId, PageRequest.of(0, 10000)).getContent();
            for (Notification n : allForUser) {
                if (n.getReadAt() == null) {
                    n.setReadAt(now);
                    notificationRepository.save(n);
                }
            }
        } else if (notificationIds != null && !notificationIds.isEmpty()) {
            List<Notification> toUpdate = notificationRepository.findByAccountIdAndUserIdAndIdIn(accountId, userId, notificationIds);
            for (Notification n : toUpdate) {
                if (n.getReadAt() == null) {
                    n.setReadAt(now);
                    notificationRepository.save(n);
                }
            }
        }
    }
}
