# AYRNOW Backend — Architecture Diagrams

ASCII diagrams for architecture overview, domain relationships, auth flow, Stripe webhook, and ledger flow.

---

## 1. System Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT (Flutter / Postman)                       │
└────────────────────────────────────┬─────────────────────────────────────────┘
                                     │ HTTPS
                                     ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                         REVERSE PROXY (Caddy / Nginx)                        │
│                         TLS termination, port 443 → 8080                     │
└────────────────────────────────────┬─────────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                     AYRNOW BACKEND (Spring Boot 3, port 8080)                 │
├──────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ JwtAuth     │  │ DevAuth     │  │ GlobalExc   │  │ SecurityConfig      │  │
│  │ Filter      │  │ Filter      │  │ Handler     │  │ (permit: health,    │  │
│  │ (Bearer)    │  │ (local)     │  │             │  │  swagger, webhook)  │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └─────────────────────┘  │
│         │               │                │                                   │
│         └───────────────┴────────────────┘                                   │
│                         │                                                    │
│                         ▼                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     CONTROLLERS (api/)                                │   │
│  │  Health, Auth, Me, Property, Unit, Lease, Invite, Ticket,             │   │
│  │  Contractor, Assignment, Post, Notification, Visitor, Ledger,        │   │
│  │  Balance, Payment, StripeWebhook, TenantProfile                      │   │
│  └────────────────────────────┬────────────────────────────────────────┘   │
│                                │                                             │
│                                ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     SERVICES (service/)                              │   │
│  │  Business logic, account scoping, role checks, idempotency           │   │
│  └────────────────────────────┬────────────────────────────────────────┘   │
│                                │                                             │
│                                ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     REPOSITORIES (domain.repository/)                │   │
│  │  JPA repositories, account-scoped queries                           │   │
│  └────────────────────────────┬────────────────────────────────────────┘   │
│                                │                                             │
│                                ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     ENTITIES (domain.entity/)                        │   │
│  │  JPA entities, soft delete (@Where, @SQLDelete)                     │   │
│  └────────────────────────────┬────────────────────────────────────────┘   │
└────────────────────────────────┼────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                     PostgreSQL (RDS / Neon / Supabase)                        │
│                     Flyway migrations on startup                             │
└──────────────────────────────────────────────────────────────────────────────┘

External:
┌─────────────┐
│ Stripe API  │ ← Checkout sessions, webhook events
└─────────────┘
```

---

## 2. Domain Relationship Diagram

```
                    ┌──────────┐
                    │ Account  │
                    └────┬─────┘
                         │ 1:N
         ┌───────────────┼───────────────┬───────────────┐
         │               │               │               │
         ▼               ▼               ▼               ▼
   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────────┐
   │ AppUser  │   │ Property │   │Contractor│   │ RefreshToken  │
   └────┬─────┘   └────┬─────┘   └────┬─────┘   └───────────────┘
        │              │              │
        │ user_roles    │ 1:N          │ assignments
        │              ▼              │
        │         ┌──────────┐        │
        │         │   Unit   │        │
        │         └────┬─────┘        │
        │              │               │
        │              │ 1:N           │
        │              ▼               │
        │         ┌──────────┐   ┌─────────────────┐
        │         │  Lease   │   │ ContractorAssign│
        │         └────┬─────┘   └────────┬────────┘
        │              │                   │
        │    unit_members, lease_tenants  │
        │              │                   │
        │              ▼                   ▼
        │         ┌─────────────────────────────┐
        │         │     MaintenanceTicket         │
        │         └──────────────┬───────────────┘
        │                        │
        │    TenantInvite ───────┤
        │    UnitMember ──────────┤
        │    CommunityPost ──────┤
        │    VisitorEntry ───────┤
        │    LedgerEntry ────────┘
        │
        └──► TenantProfile, TenantProfileExport, TenantTransferRequest
             PaymentRecord, WebhookEvent
```

---

## 3. Auth Flow (JWT + Refresh)

```
┌────────┐                    ┌────────────┐                    ┌──────────┐
│ Client │                    │   Backend  │                    │ Postgres │
└───┬────┘                    └─────┬──────┘                    └────┬─────┘
    │                                │                                │
    │  POST /auth/register           │                                │
    │  {email, password, role,      │                                │
    │   accountName}                 │                                │
    │──────────────────────────────► │   Create account, user, role    │
    │                                │───────────────────────────────►│
    │                                │                                │
    │  {accessToken, refreshToken,   │   Store refresh_token hash      │
    │   userId, accountId, role}     │◄───────────────────────────────│
    │◄──────────────────────────────│                                │
    │                                │                                │
    │  POST /auth/login              │                                │
    │  {email, password}             │                                │
    │──────────────────────────────► │   Verify password_hash         │
    │                                │───────────────────────────────►│
    │  {accessToken, refreshToken}   │                                │
    │◄──────────────────────────────│                                │
    │                                │                                │
    │  GET /api/v1/properties        │                                │
    │  Authorization: Bearer <token> │                                │
    │──────────────────────────────► │   JwtAuthFilter validates      │
    │                                │   → DevAuthPrincipal           │
    │                                │   → Service (accountId scope)  │
    │                                │                                │
    │  (access token expired)       │                                │
    │  → 401 unauthorized            │                                │
    │◄──────────────────────────────│                                │
    │                                │                                │
    │  POST /auth/refresh            │                                │
    │  {refreshToken}                │                                │
    │──────────────────────────────► │   Verify hash, rotate token    │
    │                                │   (revoke old, issue new)       │
    │  {accessToken, refreshToken}   │                                │
    │◄──────────────────────────────│                                │
    │                                │                                │
    │  POST /auth/logout             │                                │
    │  {refreshToken}                │                                │
    │──────────────────────────────► │   Mark refresh_token revoked   │
    │  204 No Content                │                                │
    │◄──────────────────────────────│                                │
```

**Local DevAuth (SPRING_PROFILES_ACTIVE=local):**  
`X-Dev-AccountId`, `X-Dev-UserId`, `X-Dev-Role` bypass JWT. Principal built from headers. Disabled in staging/prod.

---

## 4. Stripe Webhook Flow

```
┌────────┐         ┌────────────┐         ┌──────────────┐         ┌──────────┐
│ Stripe │         │  Backend   │         │ WebhookEvent │         │ Ledger    │
│        │         │  (webhook) │         │   (dedupe)   │         │           │
└───┬────┘         └─────┬──────┘         └──────┬───────┘         └────┬──────┘
    │                    │                       │                      │
    │  POST /webhook      │                       │                      │
    │  Stripe-Signature   │                       │                      │
    │  {event payload}    │                       │                      │
    │───────────────────►│                       │                      │
    │                    │  Verify signature      │                      │
    │                    │  (STRIPE_WEBHOOK_SECRET)│                      │
    │                    │                       │                      │
    │                    │  Lookup event_id       │                      │
    │                    │──────────────────────►│                      │
    │                    │  (already processed?)  │                      │
    │                    │◄──────────────────────│                      │
    │                    │                       │                      │
    │                    │  Store WebhookEvent   │                      │
    │                    │  (idempotent)         │                      │
    │                    │                       │                      │
    │                    │  checkout.session.    │                      │
    │                    │  completed →          │                      │
    │                    │  Create LedgerEntry   │                      │
    │                    │  (payment),           │                      │
    │                    │  PaymentRecord        │─────────────────────►│
    │                    │                       │                      │
    │  200 OK            │                       │                      │
    │◄───────────────────│                       │                      │
```

**Events:** `checkout.session.completed` → create ledger payment, link PaymentRecord. Duplicate events ignored via `webhook_events` table.

---

## 5. Ledger Flow (Charge → Payment → Balance)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           LEDGER LIFECYCLE                                   │
└─────────────────────────────────────────────────────────────────────────────┘

   Landlord                    Idempotency                    Tenant
      │                            │                             │
      │  POST /ledger/charges      │                             │
      │  Idempotency-Key: <uuid>   │                             │
      │  {unitId, subtype, amount, │                             │
      │   occurredOn, memo}        │                             │
      │───────────────────────────►│                             │
      │                            │  claimOrThrow (key+payload)  │
      │                            │  → LedgerEntry (type=charge) │
      │  201 + LedgerEntry         │                             │
      │◄───────────────────────────│                             │
      │                            │                             │
      │                            │  POST /ledger/payments       │
      │                            │  Idempotency-Key: <uuid>     │
      │                            │  {unitId, leaseId, amount}   │
      │                            │◄────────────────────────────│
      │                            │  → LedgerEntry (type=payment)│
      │                            │                             │
      │                            │  (OR Stripe webhook does     │
      │                            │   same via PaymentService)   │
      │                            │                             │
      │  GET /balances/units/{id}  │                             │
      │  ?asOf=2025-01-31          │                             │
      │───────────────────────────►│                             │
      │                            │  SUM(charges) - SUM(payments)│
      │                            │  + refunds - adjustments     │
      │  {balanceCents, ...}      │                             │
      │◄───────────────────────────│                             │
```

**Idempotency:** Same `Idempotency-Key` + same payload → 201 (cached). Same key + different payload → 409 conflict.

---

## Related Docs

- [HANDOFF.md](HANDOFF.md) — Layers, domain model, conventions
- [API_TESTING.md](API_TESTING.md) — Endpoint reference and curl examples
- [RUN_LOCAL.md](RUN_LOCAL.md) — Local setup
