# Changelog

All notable changes to the AYRNOW backend API.

## [0.1.0] - TBD

### B0 - Initial Setup

- Spring Boot 3.x monolith, `/api/v1` base
- Dev auth headers (X-Dev-AccountId, X-Dev-UserId, X-Dev-Role)
- PostgreSQL schema (accounts, users, user_roles, properties, units, leases)
- Flyway migrations

### B1 - Properties, Units, Leases

- Properties CRUD (create, list, get)
- Units CRUD (per property)
- Leases CRUD (tenant assignment, active lease per unit)
- Get my active lease (tenant)

### B2 - Full CRUD

- Property/Unit/Lease patch and delete
- Delete guards (409 if unit has active lease, etc.)

### B3 - Me + Membership

- GET /me (current user, account, role)
- Unit members list
- Lease tenants list

### B4 - Tenant Invites

- Create invite (email/phone, unit, role)
- List, resend, cancel invites
- Accept invite (adds user to unit_members)

### B5 - Maintenance Tickets

- Create ticket (tenant/landlord)
- List, get, patch tickets
- Add comments
- Assign contractor, close, reopen
- Role-based access (tenant: own units; landlord: full)

### B6 - Contractors + Assignments

- Contractors CRUD
- Create assignment (ticket + contractor)
- Contractor: accept, decline, complete assignment
- List assignments by contractor

### B7 - Community Posts + Notifications

- Posts (announcement, event, alert)
- Comments and reactions (like, love, laugh, sad, angry)
- Notifications for post interactions
- Mark read (by IDs or all)

### B8 - Security Visitors

- Visitor log (create entry, list)
- Property security settings (approval required)
- Security guard: create visitor; Landlord: approve/deny

### B9 - Ledger

- Ledger entries (charges, payments)
- Idempotency-Key for writes
- Balance by unit or lease
- List ledger by unit/lease

### B10 - Stripe Payments

- Checkout session creation
- Webhook handler (signature verification)
- Payment history list
- Ledger integration

### B11 - Tenant Transfer Profile

- Tenant profile export (shareable token)
- Landlord view redacted, request consent
- Tenant approve/reject
- Landlord import summary after approval
- Privacy: full details only after approval

### B12 - JWT Auth

- Register, login, refresh, logout
- Access token (JWT, 15 min), refresh token (30 days)
- JWT filter + DevAuth optional (local only)
- Token rotation on refresh

### B13 - Deployment

- Profiles: local, staging, prod
- Startup validation (fail-fast for missing secrets in staging/prod)
- Run scripts, build_jar, DEPLOY.md
- AWS EC2 + RDS deployment guide
