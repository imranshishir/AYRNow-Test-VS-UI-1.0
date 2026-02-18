# V99 Dev Reset and Seed

## Overview

`db-local/V99__dev_reset_and_seed.sql` cleans all domain data and inserts a minimal, correlated seed dataset for local development. It covers every backend module (B0–B12).

**Important:** This migration is loaded only when using the `local` Spring profile. Prod/staging use the default Flyway location (`classpath:db/migration` only) and never run V99.

---

## What Gets Truncated

`TRUNCATE accounts RESTART IDENTITY CASCADE` clears all domain tables in FK-safe order:

- accounts, users, user_roles
- properties, units, leases, lease_tenants, unit_members
- tenant_invites
- maintenance_tickets, ticket_comments
- contractors, contractor_assignments
- community_posts, post_comments, post_reactions, notifications
- property_security_settings, visitor_entries
- ledger_entries, idempotency_keys, payment_records, webhook_events
- tenant_profiles, tenant_reviews, tenant_profile_exports, tenant_transfer_requests
- refresh_tokens

---

## What Gets Inserted

| Module | Table(s) | Purpose |
|--------|----------|---------|
| B0 | accounts | 1 account: "AYRNOW Dev Account" |
| B0 | users | Landlord (`landlord@dev.com`), Tenant (`tenant@dev.com`), both password `password` |
| B0 | user_roles | landlord, tenant |
| B0 | properties | 1 property |
| B0 | units | 1 unit (occupied) |
| B0 | leases | 1 active lease |
| B3 | lease_tenants, unit_members | Tenant linked to lease and unit |
| B4 | tenant_invites | 1 pending invite |
| B5 | maintenance_tickets, ticket_comments | 1 open ticket, 1 comment |
| B6 | contractors, contractor_assignments | 1 contractor, assigned to ticket |
| B7 | community_posts, post_comments, post_reactions, notifications | 1 announcement, comment, reaction, notification |
| B8 | property_security_settings, visitor_entries | Settings + 1 pending visitor |
| B9 | ledger_entries | 1 rent charge ($1000), 1 payment ($1000), balance = 0 |
| B10 | payment_records, webhook_events | Stripe webhook simulation data |
| B11 | tenant_profiles, tenant_reviews, tenant_profile_exports, tenant_transfer_requests | Profile + approved review + export + approved transfer request |

---

## Key IDs (DevAuth / Testing)

| Entity | ID | Email/Ref |
|--------|-----|-----------|
| Account | `11111111-1111-1111-1111-111111111111` | AYRNOW Dev Account |
| Landlord | `22222222-2222-2222-2222-222222222222` | landlord@dev.com |
| Tenant | `33333333-3333-3333-3333-333333333333` | tenant@dev.com |
| Property | `44444444-4444-4444-4444-444444444444` | Dev Property |
| Unit | `55555555-5555-5555-5555-555555555555` | 101 |
| Lease | `66666666-6666-6666-6666-666666666666` | active |
| Invite | `77777777-7777-7777-7777-777777777777` | INV-DEV-001 |
| Ticket | `88888888-8888-8888-8888-888888888888` | Leaking faucet |
| Contractor | `aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa` | Dev Plumbing Co |

---

## How to Run

### Option 1: Drop & recreate DB (recommended for clean state)

```bash
dropdb ayrnow_dev
createdb ayrnow_dev
cd backend
SPRING_PROFILES_ACTIVE=local mvn spring-boot:run
```

### Option 2: Run app (V99 applies on first run with local profile)

```bash
cd backend
SPRING_PROFILES_ACTIVE=local mvn spring-boot:run
```

V99 is repeatable: each run truncates and reseeds, so you always get a clean dataset.

---

## DevAuth Headers (local profile)

```bash
# As landlord
curl -s -H "X-Dev-AccountId: 11111111-1111-1111-1111-111111111111" \
     -H "X-Dev-UserId: 22222222-2222-2222-2222-222222222222" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/properties

# As tenant
curl -s -H "X-Dev-AccountId: 11111111-1111-1111-1111-111111111111" \
     -H "X-Dev-UserId: 33333333-3333-3333-3333-333333333333" \
     -H "X-Dev-Role: tenant" \
     http://localhost:8080/api/v1/units
```

---

## JWT Login

- **Landlord:** `landlord@dev.com` / `password`
- **Tenant:** `tenant@dev.com` / `password`
