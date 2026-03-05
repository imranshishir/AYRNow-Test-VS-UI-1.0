# Dev Seed: 4-Role Demo Data

DEV ONLY. All seed data lives in `db-local/V99__dev_reset_and_seed.sql` and runs only under the `local` Spring profile. Production/staging never see this file.

---

## Demo Users

| Role | Email | Password | Display Name | UUID |
|------|-------|----------|-------------|------|
| **Landlord** | `landlord@demo.com` | `Password123!` | James Williams | `22222222-2222-2222-2222-222222222222` |
| **Tenant** | `tenant@demo.com` | `Password123!` | Alex Johnson | `33333333-3333-3333-3333-333333333333` |
| **Contractor** | `contractor@demo.com` | `Password123!` | Mike Rivera | `44444444-4444-4444-4444-444444444401` |
| **Guard** | `guard@demo.com` | `Password123!` | Sam Patel | `44444444-4444-4444-4444-444444444402` |

All users share one account: **Harlem Rd Property Management** (`11111111-1111-1111-1111-111111111111`).

---

## Data Relationships

```
Account: Harlem Rd Property Management
  └── Property: Harlem Rd Apartments (742 Harlem Rd, Buffalo, NY)
        ├── Unit A101 (occupied)
        │     ├── Lease (active, Mar 2025 – Feb 2026, tenant: Alex Johnson)
        │     │     ├── Ledger: Feb rent $1500 PAID
        │     │     └── Ledger: Mar rent $1500 DUE
        │     ├── Payment Record: Feb rent (succeeded, Stripe sim)
        │     ├── Maintenance Ticket: "Leaking kitchen faucet" (in_progress, high)
        │     │     ├── Comment: tenant → "Water is getting worse"
        │     │     ├── Comment: landlord → "Contractor assigned"
        │     │     └── Assignment: Mike Rivera (in_progress)
        │     ├── Visitor: Maria Garcia (pending – guard must approve)
        │     └── Visitor: Tom Builder (approved – completed entry log)
        │
        └── Unit A102 (vacant)
              └── Tenant Invite: pending (newrenter@example.com)

Contractor: Rivera Plumbing LLC (linked_user_id → contractor@demo.com)
Guard: Sam Patel (security_guard role)
Community: 1 announcement + 1 comment + 1 reaction + 1 notification
Tenant Profile: Alex Johnson (5★ review, active export, approved transfer)
```

---

## How to Run

### Prerequisites
- PostgreSQL 15+ running locally
- Java 17+, Maven 3.8+

### Start fresh

```bash
# Reset database
dropdb ayrnow_dev 2>/dev/null; createdb ayrnow_dev

# Run backend (Flyway applies V1–V100 + V99 seed)
cd backend
SPRING_PROFILES_ACTIVE=local mvn spring-boot:run
```

### Verify health

```bash
curl -s http://localhost:8080/api/v1/health
# {"status":"ok"}
```

---

## Login: curl Commands

### Landlord

```bash
curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"landlord@demo.com","password":"Password123!"}' | jq .
```

### Tenant

```bash
curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"tenant@demo.com","password":"Password123!"}' | jq .
```

### Contractor

```bash
curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"contractor@demo.com","password":"Password123!"}' | jq .
```

### Guard

```bash
curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"guard@demo.com","password":"Password123!"}' | jq .
```

### Use the token

```bash
# Replace <TOKEN> with the accessToken from login response
curl -s http://localhost:8080/api/v1/me \
  -H "Authorization: Bearer <TOKEN>" | jq .
```

---

## Verification Checklist

### Landlord (`landlord@demo.com`)

- [ ] Login returns JWT with `role: "landlord"`
- [ ] `GET /api/v1/me` returns user info
- [ ] `GET /api/v1/properties` returns "Harlem Rd Apartments"
- [ ] `GET /api/v1/units` returns Unit A101 (occupied) + A102 (vacant)
- [ ] `GET /api/v1/leases` returns 1 active lease
- [ ] `GET /api/v1/tickets` returns "Leaking kitchen faucet" (in_progress)
- [ ] Rent board shows Feb (paid) and Mar (due)
- [ ] Ticket detail shows contractor assignment

### Tenant (`tenant@demo.com`)

- [ ] Login returns JWT with `role: "tenant"`
- [ ] `GET /api/v1/me` returns user info
- [ ] Active lease visible (Mar 2025 – Feb 2026, $1500/mo)
- [ ] Ledger shows Feb payment ($1500 paid)
- [ ] Ledger shows Mar rent ($1500 due)
- [ ] Ticket "Leaking kitchen faucet" visible with comments
- [ ] Tenant profile with 5★ review accessible

### Contractor (`contractor@demo.com`)

- [ ] Login returns JWT with `role: "contractor"`
- [ ] `GET /api/v1/me` returns user info
- [ ] Contractor assignment visible (in_progress)
- [ ] Linked to ticket "Leaking kitchen faucet"
- [ ] Earnings record linked via payment flow

### Guard (`guard@demo.com`)

- [ ] Login returns JWT with `role: "security_guard"`
- [ ] `GET /api/v1/me` returns user info
- [ ] Pending visitor "Maria Garcia" visible
- [ ] Completed entry "Tom Builder" (approved by guard) visible

---

## Key UUIDs (for DevAuth headers)

| Entity | UUID |
|--------|------|
| Account | `11111111-1111-1111-1111-111111111111` |
| Landlord user | `22222222-2222-2222-2222-222222222222` |
| Tenant user | `33333333-3333-3333-3333-333333333333` |
| Contractor user | `44444444-4444-4444-4444-444444444401` |
| Guard user | `44444444-4444-4444-4444-444444444402` |
| Property | `55555555-5555-5555-5555-555555555555` |
| Unit A101 | `66666666-6666-6666-6666-666666666601` |
| Unit A102 | `66666666-6666-6666-6666-666666666602` |
| Lease | `77777777-7777-7777-7777-777777777777` |
| Ticket | `88888888-8888-8888-8888-888888888888` |
| Contractor record | `aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa` |

### DevAuth headers (local profile only)

```bash
# As guard
curl -s -H "X-Dev-AccountId: 11111111-1111-1111-1111-111111111111" \
     -H "X-Dev-UserId: 44444444-4444-4444-4444-444444444402" \
     -H "X-Dev-Role: security_guard" \
     http://localhost:8080/api/v1/visitors
```

---

## Notes

- V99 **truncates all data** on every run, so the dataset is always clean.
- V100 adds a separate `test@test.com` / `test123` user (original test account).
- BCrypt hash uses `$2a$10$` prefix (Java BCrypt compatible).
- Roles are plain strings in `user_roles.role`: `landlord`, `tenant`, `contractor`, `security_guard`.
- This seed is **idempotent** via the TRUNCATE + INSERT pattern.
- No production data, schema changes, or JWT hardcoding involved.
