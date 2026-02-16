# Developer Handoff Guide — AYRNOW Backend

For engineers joining the project. Read this first.

---

## System Overview

**Stack:** Spring Boot 3.x, Java 17, PostgreSQL 15, Flyway, JWT + Stripe + Ledger.

**Architecture:** Monolithic REST API under `/api/v1`. No Docker; JAR deploy.

### Layers

| Layer | Path | Responsibility |
|-------|------|----------------|
| **api** | `com.ayrnow.api` | Controllers, DTOs, `GlobalExceptionHandler`, `ConflictException`, `ResourceNotFoundException` |
| **service** | `com.ayrnow.service` | Business logic, orchestration, access checks |
| **repository** | `com.ayrnow.domain.repository` | JPA repositories (AccountRepository, LedgerEntryRepository, etc.) |
| **domain/entity** | `com.ayrnow.domain.entity` | JPA entities |
| **security** | `com.ayrnow.security` | `DevAuthPrincipal`, `JwtAuthFilter`, `DevAuthFilter` (local only), `SecurityConfig` |
| **config** | `com.ayrnow.config` | `AuthProperties`, `StartupValidator`, `PasswordEncoderConfig` |

### Request Flow

```
HTTP Request → JwtAuthFilter (Bearer) or DevAuthFilter (local) → Controller → Service → Repository → DB
                ↓
          DevAuthPrincipal (accountId, userId, role)
                ↓
          Service enforces account scoping + role checks
```

---

## Domain Model Summary

| Domain | Key Entities | Purpose |
|--------|--------------|---------|
| **Account / User** | `Account`, `AppUser`, `UserRole` | Multi-tenant; user belongs to one account; roles in `user_roles` |
| **Property / Unit** | `Property`, `Unit` | Properties contain units; soft-deleted via `deleted_at` |
| **Lease** | `Lease`, `LeaseTenant` | One active lease per unit; tenant(s) via `LeaseTenant` |
| **Unit Members** | `UnitMember` | Who belongs to a unit (from invite accept or lease) |
| **Invites** | `TenantInvite` | Pending invite per unit; accept adds to `unit_members` |
| **Tickets** | `MaintenanceTicket`, `TicketComment` | Maintenance requests; assign to contractor |
| **Contractors** | `Contractor`, `ContractorAssignment` | Contractors per account; assignments link ticket↔contractor |
| **Posts / Notifications** | `CommunityPost`, `PostComment`, `PostReaction`, `Notification` | Community feed, reactions, notifications |
| **Security** | `PropertySecuritySettings`, `VisitorEntry` | Per-property approval; visitor log with approve/deny |
| **Ledger** | `LedgerEntry`, `IdempotencyKeyRecord` | Charges, payments, refunds, adjustments; idempotent writes |
| **Stripe** | `PaymentRecord`, `WebhookEvent` | Checkout sessions; webhook processing; ledger integration |
| **Tenant Transfer** | `TenantProfile`, `TenantReview`, `TenantProfileExport`, `TenantTransferRequest` | Export share token; landlord request; tenant approve; import summary |
| **Auth** | `RefreshToken` | JWT refresh tokens; hashed; rotation on use |

---

## Conventions

### Account Scoping Rule

Every query is filtered by `accountId` from the authenticated principal. Cross-account access is never permitted. Controllers pass `principal.accountId()` to services; services enforce it on every DB call.

### Error Envelope Shape

```json
{
  "error": "error_code",
  "message": "Human-readable message",
  "fields": { "fieldName": "validation message" }
}
```

| HTTP | `error` | When |
|------|---------|------|
| 400 | `validation_error` | `@Valid` fails; `fields` present |
| 400 | `bad_request` | Business rule (e.g. unit has active lease) |
| 401 | `unauthorized` | Missing/invalid auth |
| 403 | `forbidden` | Valid auth, insufficient role |
| 404 | `not_found` | Resource missing or not in account |
| 409 | `conflict` | State conflict (e.g. duplicate pending invite) |
| 500 | `internal_error` | Unexpected |

### Pagination Pattern `PageResponse`

```json
{
  "content": [...],
  "page": 0,
  "size": 20,
  "totalElements": 42,
  "totalPages": 3,
  "first": true,
  "last": false
}
```

Params: `page` (default 0), `size` (default 20).

### Idempotency Rules

- **Ledger writes:** `charges`, `payments`, `refunds`, `adjustments` require `Idempotency-Key` header. Same key + same payload → returns cached response (201). Same key + different payload → 409.
- **Webhook dedupe:** Stripe webhook stores `WebhookEvent` by event ID; duplicate events are ignored.

### Soft Delete Behavior

- **Property** and **Unit:** `deleted_at`; `@Where(clause = "deleted_at IS NULL")`; `@SQLDelete` sets `deleted_at` instead of DELETE.
- **Contractor:** `status = 'inactive'` (logical deactivation).

---

## How to Add a New Feature Safely

### Step 1: Flyway Migration

1. Create `backend/src/main/resources/db/migration/V<next>__description.sql`.
2. Prefer additive changes.
3. Add indexes for query patterns.

**Existing migrations:** V1 (init), V2 (dev seed), V3–V4 (lease uniqueness, soft delete), V5 (unit_members), V6 (lease_tenants), V7 (invites), V8 (tickets), V9 (contractors), V10 (posts), V11 (security/visitors), V12 (ledger), V13 (Stripe), V14 (tenant transfer), V15 (auth).

### Step 2: Entity + Repository

1. Add entity in `domain.entity` with `@Entity`, `@Table`, proper `@Column`/`@ManyToOne`.
2. Add repository in `domain.repository` extending `JpaRepository<Entity, UUID>`.
3. Add account-scoped methods: `findByAccountIdAndId`, `findByAccountId...`, etc.

### Step 3: Service

1. Add service in `com.ayrnow.service`.
2. Inject repos; enforce `accountId` on all queries.
3. Throw `ResourceNotFoundException` (404), `ConflictException` (409), `AccessDeniedException` (403) as appropriate.
4. Use `@Transactional` for write operations.

### Step 4: DTOs

1. Add request/response records in `com.ayrnow.api.dto`.
2. Use `@Valid` + Jakarta validation on request DTOs.

### Step 5: Controller

1. Add controller with `@RestController`, `@RequestMapping("/api/v1/...")`.
2. Use `@AuthenticationPrincipal DevAuthPrincipal principal`.
3. Pass `principal.accountId()`, `principal.userId()`, `principal.role()` to service.
4. Return `PageResponse` for paginated lists.

### Step 6: Access Rules

- Identify roles: landlord, manager, owner, tenant, family, cotenant/co_tenant, contractor, security_guard. (`property_manager`/`pm` normalize to `manager`.)
- Enforce in service: `if (!isLandlord(...)) throw new AccessDeniedException(...)`.
- Document in [API_TESTING.md](API_TESTING.md).

### Step 7: README Curl Examples

1. Add curl examples to `backend/README.md` and [API_TESTING.md](API_TESTING.md).
2. Use placeholders: `<ACCESS_TOKEN>`, `<PROPERTY_ID>`, etc.

---

## Roadmap

- **Security guard scoping by property assignment:** Guard only sees visitors for assigned properties.
- **Mobile integration:** API shape ready; consider mobile-specific endpoints or headers.
- **Admin dashboard endpoints:** Bulk ops, analytics, user management.
- **Tests:** Add unit + integration tests; coverage for services and controllers.
- **Rate limiting:** Per-IP or per-user limits on auth and write endpoints.
- **Observability:** Structured logging, metrics (Actuator), distributed tracing (optional).

---

## Related Docs

- [RUN_LOCAL.md](RUN_LOCAL.md) — Run locally
- [API_TESTING.md](API_TESTING.md) — Full API reference + curl examples
- [DEPLOY.md](DEPLOY.md) — Staging/prod deployment
