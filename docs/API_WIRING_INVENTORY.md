# AYRNOW API Wiring Inventory & Finish-to-Prod Scope

**Branch:** `audit/api-wiring-inventory`  
**Date:** 2026-02-19  
**Scope:** Backend API inventory, DB read/write verification, Flutter wiring, gap report, V1 finish plan.

---

## 1. Numeric Summary

| Metric | Count |
|--------|-------|
| **Total backend endpoints found** | 28 |
| **Implemented (real service + repo)** | 25 |
| **Partial (controller + service but stub/edge case)** | 1 (Payment: Stripe optional stub) |
| **STUB (no DB / hardcoded response)** | 2 (StripeWebhookController; TenantTransfer profile docs hardcoded) |
| **Missing (frontend expects, backend lacks)** | 2 (contractor jobs, guard approvals — no controllers) |
| **Wired in Flutter (real HTTP call)** | 2 (POST /v1/auth/login, GET /v1/me) |
| **Not wired (Flutter uses MockRepos)** | 26 |
| **Endpoints that READ and/or WRITE DB** | 26 |
| **Endpoints with NO DB (stub only)** | 2 (webhook POST; N/A for auth/me) |

---

## 2. Backend API Inventory (by module)

### Auth
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| POST | /v1/auth/login | AuthController | login | IMPLEMENTED | WRITES (UserRepository: findOrCreate, save) |

### Me (current user)
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| GET | /v1/me | MeController | me | IMPLEMENTED | READS (UserRepository.findById) |

### Properties
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| GET | /v1/properties | PropertyController | list | IMPLEMENTED | READS (PropertyRepository, AccessControlService → Property/Unit/Membership) |
| GET | /v1/properties/{propertyId}/units | PropertyController | listUnits | IMPLEMENTED | READS (UnitRepository, AccessControlService) |

### Rent board
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| GET | /v1/rent-board | RentBoardController | list | IMPLEMENTED | READS (Unit, Membership, LedgerEntry, Payment repos) |

### Tickets (Maintenance)
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| GET | /v1/tickets | TicketController | list | IMPLEMENTED | READS (TicketRepository, AccessControl, TicketComment) |
| GET | /v1/tickets/{id} | TicketController | get | IMPLEMENTED | READS (Ticket, TicketComment, User, Unit) |
| POST | /v1/tickets | TicketController | create | IMPLEMENTED | WRITES (TicketRepository.save, NotificationService) |
| POST | /v1/tickets/{id}/comments | TicketController | addComment | IMPLEMENTED | WRITES (TicketCommentRepository, NotificationService) |
| PATCH | /v1/tickets/{id} | TicketController | updateStatus | IMPLEMENTED | WRITES (TicketRepository.save, NotificationService) |

### Payments
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| POST | /v1/payments/intent | PaymentController | createIntent | IMPLEMENTED (Stripe optional) | WRITES (Payment, LedgerEntry, NotificationService); when Stripe key empty → stubbed payment + ledger + notification |

### Webhooks
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| POST | /v1/webhooks/stripe | StripeWebhookController | handle | STUB | NO DB (returns 200, no service) |

### Community
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| GET | /v1/community/posts | CommunityController | listPosts | IMPLEMENTED | READS (CommunityPostRepository, AccessControl) |
| POST | /v1/community/posts | CommunityController | createPost | IMPLEMENTED | WRITES (CommunityPostRepository, NotificationService) |
| GET | /v1/community/posts/{postId}/comments | CommunityController | listComments | IMPLEMENTED | READS (CommunityCommentRepository) |
| POST | /v1/community/posts/{postId}/comments | CommunityController | addComment | IMPLEMENTED | WRITES (CommunityCommentRepository, CommunityPost comment_count, NotificationService) |

### Notifications
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| GET | /v1/notifications | NotificationController | list | IMPLEMENTED | READS (NotificationRepository) |
| POST | /v1/notifications/{id}/read | NotificationController | markRead | IMPLEMENTED | WRITES (NotificationRepository.save) |
| POST | /v1/notifications/mark-all-read | NotificationController | markAllRead | IMPLEMENTED | WRITES (NotificationRepository bulk update) |

### Tenant transfer
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| GET | /v1/tenant-transfer/profile | TenantTransferController | getProfile | IMPLEMENTED (docs stub) | READS (User, Membership, Unit, Property); profile documents hardcoded ("d1", "d2", "missing") |
| GET | /v1/tenant-transfer/my-request | TenantTransferController | getMyRequest | IMPLEMENTED | READS (TransferRequestRepository) |
| POST | /v1/tenant-transfer/requests | TenantTransferController | createRequest | IMPLEMENTED | WRITES (TransferRequestRepository, NotificationService) |
| GET | /v1/tenant-transfer/inbox | TenantTransferController | listInbox | IMPLEMENTED | READS (TransferRequestRepository) |
| POST | /v1/tenant-transfer/requests/{id}/decision | TenantTransferController | decide | IMPLEMENTED | WRITES (TransferRequestRepository, Membership, NotificationService) |

### Household
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| GET | /v1/household/members | HouseholdController | listMembers | IMPLEMENTED | READS (HouseholdMemberRepository, AccessControl) |
| POST | /v1/household/members/invite | HouseholdController | inviteMember | IMPLEMENTED | WRITES (HouseholdMemberRepository, NotificationService) |
| POST | /v1/household/members/{memberId}/deactivate | HouseholdController | deactivateMember | IMPLEMENTED | WRITES (HouseholdMemberRepository status update) |

### Onboarding (landlord property/unit setup)
| Method | Path | Controller | Handler | Status | DB |
|--------|------|------------|---------|--------|-----|
| POST | /v1/onboarding/property | OnboardingController | createProperty | IMPLEMENTED | WRITES (PropertyRepository, UnitRepository) |
| POST | /v1/onboarding/unit/{unitId}/assign-tenant | OnboardingController | assignTenant | IMPLEMENTED | WRITES (UserRepository, MembershipRepository) |

---

## 3. Backend DB Read/Write Verification

- **Auth:** UserRepository findByEmail, save (create or update user). Transactional.
- **Me:** UserRepository findById. Read only.
- **Properties:** PropertyRepository, UnitRepository, AccessControlService (Property, Unit, Membership). Read only.
- **Rent board:** UnitRepository, MembershipRepository, LedgerEntryRepository, PaymentRepository. Read only. (N+1 possible: units → memberships per unit; consider batch if needed.)
- **Tickets:** TicketRepository, TicketCommentRepository, UnitRepository, UserRepository, PropertyRepository, NotificationService. Read + Write. Write flows use @Transactional.
- **Payments:** PaymentRepository, LedgerEntryRepository, UnitRepository, PropertyRepository, NotificationService. Write. @Transactional. When Stripe key blank: still writes Payment + LedgerEntry + notification (stubbed client_secret).
- **Stripe webhook:** No service, no DB. STUB.
- **Community:** CommunityPostRepository, CommunityCommentRepository, UserRepository, UnitRepository, MembershipRepository, AccessControlService, NotificationService. Read + Write. @Transactional on createPost, addComment.
- **Notifications:** NotificationRepository. Read + Write. @Transactional on markRead, markAllRead, notifyUser.
- **Tenant transfer:** UserRepository, TransferRequestRepository, MembershipRepository, UnitRepository, PropertyRepository, NotificationService. Read + Write. Profile returns hardcoded docs list (PARTIAL). @Transactional on createRequest, decide.
- **Household:** HouseholdMemberRepository, UnitRepository, PropertyRepository, MembershipRepository, AccessControlService, NotificationService. Read + Write. @Transactional on inviteMember, deactivateMember.
- **Onboarding:** PropertyRepository, UnitRepository, UserRepository, MembershipRepository, HouseholdMemberRepository, AccessControlService. Write only. @Transactional.

**Entities/tables involved:** users, properties, units, memberships, tickets, ticket_comments, notifications, payments, ledger_entries, community_posts, community_comments, transfer_requests, household_members. All have JPA entities and Flyway migrations (V1–V6, seed V2/V4/V20).

**Suspicious patterns noted:**
- **Stripe webhook:** No signature verification, no DB; not production-safe.
- **Tenant transfer profile:** Document list is hardcoded ("missing"); no document storage API yet.
- **MeController / MeResponse:** Returns DTO (id, email, name, role); not leaking entity. OK.
- **Rent board:** List endpoint may do multiple queries per unit (memberships); acceptable for V1; monitor N+1 if properties grow.
- **Flyway:** All entities covered by migrations; no mismatch observed.

---

## 4. Frontend Wiring Inventory

| Backend endpoint | Flutter call site | Wired? | Notes |
|------------------|-------------------|--------|-------|
| POST /v1/auth/login | providers.dart AuthController.login | Yes | Real HTTP via http.post; token persisted. |
| GET /v1/me | providers.dart initialSessionProvider | Yes | Real HTTP via http.get; session restore. |
| GET /v1/properties | — | No | reposProvider → MockRepos; no API. |
| GET /v1/properties/{id}/units | — | No | MockRepos. |
| GET /v1/rent-board | — | No | MockRepos.listRentBoard() (mock list). |
| GET /v1/tickets | — | No | MockRepos.listTickets(). |
| GET /v1/tickets/{id} | — | No | Mock. |
| POST /v1/tickets | — | No | Mock. |
| POST /v1/tickets/{id}/comments | — | No | Mock. |
| PATCH /v1/tickets/{id} | — | No | Mock. |
| POST /v1/payments/intent | — | No | t10_pay_rent uses repos.simulatePayment (mock). |
| GET /v1/community/posts | — | No | MockCommunityRepo.listPosts. |
| POST /v1/community/posts | — | No | MockCommunityRepo.createPost. |
| GET /v1/community/posts/{id}/comments | — | No | MockCommunityRepo.listComments. |
| POST /v1/community/posts/{id}/comments | — | No | MockCommunityRepo.addComment. |
| GET /v1/notifications | — | No | Mock (no provider calling backend). |
| POST /v1/notifications/{id}/read | — | No | — |
| POST /v1/notifications/mark-all-read | — | No | — |
| GET /v1/tenant-transfer/profile | — | No | MockTenantTransferRepo.getMyTenantProfile. |
| GET /v1/tenant-transfer/my-request | — | No | MockTenantTransferRepo.getMyActiveTransferRequest. |
| POST /v1/tenant-transfer/requests | — | No | Mock. |
| GET /v1/tenant-transfer/inbox | — | No | MockTenantTransferRepo.listTransferRequestsForLandlord. |
| POST /v1/tenant-transfer/requests/{id}/decision | — | No | Mock. |
| GET /v1/household/members | — | No | MockHouseholdRepo.listMembers. |
| POST /v1/household/members/invite | — | No | MockHouseholdRepo.inviteMember. |
| POST /v1/household/members/{id}/deactivate | — | No | Mock. |
| POST /v1/onboarding/property | — | No | No Flutter screen found calling this. |
| POST /v1/onboarding/unit/{id}/assign-tenant | — | No | No Flutter screen found. |
| POST /v1/webhooks/stripe | — | No | Backend-only; Flutter does not call. |

**Summary:** Only **2** backend routes are called from Flutter: **POST /v1/auth/login** and **GET /v1/me**. All other UI data comes from **MockRepos** (MockCommunityRepo, MockTenantTransferRepo, MockHouseholdRepo, and in-memory lists in MockRepos for rent, tickets, jobs, approvals).

---

## 5. Gap Report (one row per endpoint)

| Module | Method + Path | Backend status | DB behavior | Flutter wired? | Notes |
|--------|----------------|----------------|-------------|----------------|-------|
| Auth | POST /v1/auth/login | Implemented | WRITES | Yes | Done. |
| Me | GET /v1/me | Implemented | READS | Yes | Done. |
| Properties | GET /v1/properties | Implemented | READS | No | Wire list properties to replace mock. |
| Properties | GET /v1/properties/{id}/units | Implemented | READS | No | Wire list units. |
| Rent | GET /v1/rent-board | Implemented | READS | No | Wire rent board; replace MockRepos.listRentBoard. |
| Maintenance | GET /v1/tickets | Implemented | READS | No | Wire list tickets. |
| Maintenance | GET /v1/tickets/{id} | Implemented | READS | No | Wire ticket detail. |
| Maintenance | POST /v1/tickets | Implemented | WRITES | No | Wire create ticket. |
| Maintenance | POST /v1/tickets/{id}/comments | Implemented | WRITES | No | Wire add comment. |
| Maintenance | PATCH /v1/tickets/{id} | Implemented | WRITES | No | Wire update status. |
| Payments | POST /v1/payments/intent | Implemented | WRITES | No | Wire pay rent; replace simulatePayment. |
| Webhooks | POST /v1/webhooks/stripe | Stub | NO DB | N/A | Implement verification + Payment status update for prod. |
| Community | GET /v1/community/posts | Implemented | READS | No | Wire posts; replace MockCommunityRepo. |
| Community | POST /v1/community/posts | Implemented | WRITES | No | Wire create post. |
| Community | GET /v1/community/posts/{id}/comments | Implemented | READS | No | Wire comments. |
| Community | POST /v1/community/posts/{id}/comments | Implemented | WRITES | No | Wire add comment. |
| Notifications | GET /v1/notifications | Implemented | READS | No | Wire notifications list. |
| Notifications | POST /v1/notifications/{id}/read | Implemented | WRITES | No | Wire mark read. |
| Notifications | POST /v1/notifications/mark-all-read | Implemented | WRITES | No | Wire mark all read. |
| Tenant transfer | GET /v1/tenant-transfer/profile | Implemented (docs stub) | READS | No | Wire profile; docs hardcoded. |
| Tenant transfer | GET /v1/tenant-transfer/my-request | Implemented | READS | No | Wire my request. |
| Tenant transfer | POST /v1/tenant-transfer/requests | Implemented | WRITES | No | Wire create request. |
| Tenant transfer | GET /v1/tenant-transfer/inbox | Implemented | READS | No | Wire landlord inbox. |
| Tenant transfer | POST /v1/tenant-transfer/requests/{id}/decision | Implemented | WRITES | No | Wire decide. |
| Household | GET /v1/household/members | Implemented | READS | No | Wire list members. |
| Household | POST /v1/household/members/invite | Implemented | WRITES | No | Wire invite. |
| Household | POST /v1/household/members/{id}/deactivate | Implemented | WRITES | No | Wire deactivate. |
| Onboarding | POST /v1/onboarding/property | Implemented | WRITES | No | Wire from landlord onboarding flow if present. |
| Onboarding | POST /v1/onboarding/unit/{id}/assign-tenant | Implemented | WRITES | No | Wire assign tenant. |

---

## 6. Finish-to-Prod Scope Plan (V1 minimal)

**V1 “Done” scope:** Auth (done), Property/Unit listing, Rent board, Maintenance (tickets + comments + status), Payments (create intent / stubbed or Stripe), Community (posts + comments), Notifications (list + mark read), Tenant transfer (profile + request + inbox + decision), Household (members + invite + deactivate). Onboarding optional for V1 if landlord onboarding UI exists. **Out of scope for this inventory:** Contractor jobs and Guard approvals (no backend endpoints; Flutter uses mock only).

### Prioritized punch list (max 20 items)

**Tier 1 – Auth & integrity (highest risk)**  
1. **Auth already wired.** Verify: Login screen → token → GET /v1/me → home. Curl: `POST /v1/auth/login` then `GET /v1/me` with Bearer token.  
2. **Stripe webhook (prod):** Implement signature verification and update Payment status from Stripe events. Files: `StripeWebhookController`, new/updated `PaymentService` webhook handler. Verify: Stripe CLI forward + test event.  
3. **JWT & permissions:** Confirm all /v1/** (except /v1/auth/login, /v1/webhooks/**) require auth. File: `SecurityConfig`. Verify: curl without token returns 401.

**Tier 2 – Wire core flows (replace MockRepos)**  
4. **Properties + units:** Add API client in Flutter (e.g. `ApiPropertyRepo`) calling GET /v1/properties and GET /v1/properties/{id}/units. Switch `reposProvider` or add `apiReposProvider` that uses real API when token present. Files: Flutter `lib/core/backend/` or `lib/core/repos/`, providers. Verify: curl with token; Flutter Properties/Units screen shows backend data.  
5. **Rent board:** Wire GET /v1/rent-board. Flutter: replace `listRentBoard()` mock with HTTP GET. Verify: curl `GET /v1/rent-board?propertyId=...`; Flutter rent board screen.  
6. **Tickets list + detail:** Wire GET /v1/tickets and GET /v1/tickets/{id}. Verify: curl; Flutter maintenance/ticket screens.  
7. **Create ticket:** Wire POST /v1/tickets. Verify: curl POST body; Flutter create-ticket flow.  
8. **Ticket comments + status:** Wire POST /v1/tickets/{id}/comments and PATCH /v1/tickets/{id}. Verify: curl; Flutter ticket detail.  
9. **Payments:** Wire POST /v1/payments/intent. Replace `simulatePayment` with API call. Verify: curl POST /v1/payments/intent with unitId; Flutter pay rent screen.  
10. **Notifications:** Wire GET /v1/notifications, POST /v1/notifications/{id}/read, POST /v1/notifications/mark-all-read. Verify: curl; Flutter notifications screen if present.

**Tier 3 – Community, transfer, household**  
11. **Community posts:** Wire GET/POST /v1/community/posts. Verify: curl; Flutter community screen.  
12. **Community comments:** Wire GET/POST /v1/community/posts/{id}/comments. Verify: curl; Flutter post detail.  
13. **Tenant transfer profile + request:** Wire GET /v1/tenant-transfer/profile, GET /v1/tenant-transfer/my-request, POST /v1/tenant-transfer/requests. Verify: curl; Flutter tenant transfer screens.  
14. **Tenant transfer inbox + decision:** Wire GET /v1/tenant-transfer/inbox, POST /v1/tenant-transfer/requests/{id}/decision. Verify: curl; Flutter landlord transfer inbox.  
15. **Household:** Wire GET /v1/household/members, POST /v1/household/members/invite, POST /v1/household/members/{id}/deactivate. Verify: curl; Flutter household screens.

**Tier 4 – Onboarding & hardening**  
16. **Onboarding (if UI exists):** Wire POST /v1/onboarding/property and POST /v1/onboarding/unit/{id}/assign-tenant. Files: Flutter onboarding flow. Verify: curl; create property then assign tenant.  
17. **Validation:** Ensure all DTOs have @Valid and sensible constraints. Files: backend dto package. Verify: send invalid payloads → 400.  
18. **Error handling:** Consistent error response shape; Flutter maps to user message. Files: GlobalExceptionHandler, Flutter API client. Verify: 404/403/400 from backend show in UI.  
19. **Logging:** Request logging (e.g. filter) and error logs for write paths. Files: config, controllers. Verify: logs on key operations.  
20. **Tenant transfer profile documents:** Replace hardcoded docs in TenantTransferService.getMyProfile with real document references or explicit “no docs” response. File: TenantTransferService, TenantProfileResponse. Verify: GET /v1/tenant-transfer/profile returns consistent structure.

---

## 7. Verification Commands (quick reference)

```bash
# Backend health
curl -s http://127.0.0.1:8081/actuator/health

# Login
curl -s -X POST http://127.0.0.1:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"landlord@demo.com","role":"landlord"}'

# Me (set TOKEN from login response)
curl -s -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8081/v1/me

# Properties
curl -s -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8081/v1/properties

# Rent board
curl -s -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8081/v1/rent-board"

# Notifications
curl -s -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8081/v1/notifications"
```

---

*End of inventory. No code changes; analysis and plan only.*
