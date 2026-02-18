# AYRNOW Backend

Spring Boot 3.x monolithic API for AYRNOW. REST JSON, versioned under `/api/v1`.

## Documentation

| Doc | Description |
|-----|-------------|
| [documentation/backend/README.md](../documentation/backend/README.md) | Documentation index, what is AYRNOW backend, quick start |
| [documentation/backend/HANDOFF.md](../documentation/backend/HANDOFF.md) | Developer handoff: architecture, domain model, conventions, how to add features |
| [documentation/backend/ARCHITECTURE_DIAGRAM.md](../documentation/backend/ARCHITECTURE_DIAGRAM.md) | ASCII diagrams: system, domain, auth, Stripe webhook, ledger |
| [documentation/backend/RUN_LOCAL.md](../documentation/backend/RUN_LOCAL.md) | Run locally: prereqs, DB setup, Flyway, common issues, auth modes |
| [documentation/backend/API_TESTING.md](../documentation/backend/API_TESTING.md) | Full API reference with curl examples for every endpoint |
| [documentation/backend/DEPLOY.md](../documentation/backend/DEPLOY.md) | Staging/prod deployment, AWS EC2+RDS, systemd, HTTPS, Stripe webhooks |
| [Swagger UI](http://localhost:8080/swagger-ui.html) | Interactive API docs (when running locally) |

Postman: Import [documentation/backend/postman/AYRNOW.postman_collection.json](../documentation/backend/postman/AYRNOW.postman_collection.json). Set `BASE_URL` and `ACCESS_TOKEN` in variables.

## Prerequisites

- Java 17+
- Maven 3.8+
- PostgreSQL with database `ayrnow_dev` (localhost:5432)

## Run Locally

```bash
cd backend
./scripts/run_local.sh
```

Or manually:
```bash
cd backend
export SPRING_PROFILES_ACTIVE=local
mvn spring-boot:run
```

**Deployment:** See [docs/DEPLOY.md](docs/DEPLOY.md) for staging/prod config, scripts, and go-live checklist. Scripts: `./scripts/run_local.sh`, `./scripts/run_staging.sh`, `./scripts/run_prod.sh`, `./scripts/build_jar.sh`.

Or with explicit DB vars:

```bash
cd backend
export SPRING_PROFILES_ACTIVE=local
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/ayrnow_dev
export SPRING_DATASOURCE_USERNAME=imranshishir
export SPRING_DATASOURCE_PASSWORD=
mvn spring-boot:run
```

## Auth (Phase B0 + B12)

### Option A: Dev Auth headers (local only)

When running with `SPRING_PROFILES_ACTIVE=local`, you can use dev headers for fast testing:

- `X-Dev-AccountId`: UUID of the account
- `X-Dev-UserId`: UUID of the user
- `X-Dev-Role`: Role string (e.g. `landlord`, `tenant`)

Missing or invalid headers → 401 Unauthorized.

**Dev headers are disabled in production** (auth.dev-headers-enabled=false).

### Option B: JWT (register / login)

For production or when testing real auth, use JWT Bearer tokens:

1. Register or login to get `accessToken` and `refreshToken`
2. Call APIs with `Authorization: Bearer <accessToken>`
3. Refresh when access token expires (15 min default)
4. Logout to revoke refresh token

## Curl Examples

**Base URL:** `http://localhost:8080`

**Dev headers** (from V2 seed):
```
X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001
X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001
X-Dev-Role: landlord
```

### Health (no auth)
```bash
curl -s http://localhost:8080/api/v1/health
# {"status":"ok"}
```

### Phase B12: JWT Auth flow

#### Register
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -d '{"email":"jwt@example.com","password":"securepass123","displayName":"JWT User","role":"landlord","accountName":"My Property Co"}' \
     http://localhost:8080/api/v1/auth/register
# Returns: { "accessToken": "...", "refreshToken": "...", "userId": "...", "accountId": "...", "role": "landlord" }
# Save accessToken and refreshToken for next steps
```

#### Login
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -d '{"email":"jwt@example.com","password":"securepass123"}' \
     http://localhost:8080/api/v1/auth/login
# Returns same token response
```

**Test login:** `test@test.com` / `test123`. Use for JWT login in Flutter or curl.

#### List properties with Bearer token
```bash
# Replace TOKEN with accessToken from register/login
curl -s -H "Authorization: Bearer TOKEN" \
     http://localhost:8080/api/v1/properties
```

#### Refresh
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -d '{"refreshToken":"REFRESH_TOKEN_FROM_LOGIN"}' \
     http://localhost:8080/api/v1/auth/refresh
# Returns new accessToken + refreshToken (old refresh token is revoked)
```

#### Logout
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -d '{"refreshToken":"REFRESH_TOKEN"}' \
     http://localhost:8080/api/v1/auth/logout
# 204 No Content
```

### List properties (Option A: Dev headers)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/properties
```

### Create property
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"name":"Elm Street Apartments","address1":"123 Elm St","city":"Buffalo","state":"NY","postalCode":"14201"}' \
     http://localhost:8080/api/v1/properties
```

### List units for a property
```bash
# Replace {propertyId} with actual UUID from create response
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/properties/{propertyId}/units
```

### Create unit (Phase B1)
```bash
# Replace {propertyId} with actual UUID from create property response
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"unitLabel":"Apt 101","status":"vacant"}' \
     http://localhost:8080/api/v1/properties/{propertyId}/units
```

### Get my active lease (tenant)
```bash
# Returns 404 if no active lease
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     http://localhost:8080/api/v1/leases/me/active
```

### Create lease (Phase B1)
```bash
# Replace {unitId} with UUID from create unit response
# tenantUserId: bbbbbbbb-0000-0000-0000-000000000001 (dev user)
# Only one active lease per unit; returns 400 if unit already has active lease
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"unitId":"{unitId}","tenantUserId":"bbbbbbbb-0000-0000-0000-000000000001","startDate":"2025-01-01","endDate":"2025-12-31"}' \
     http://localhost:8080/api/v1/leases
```

### Phase B2: Properties CRUD

#### Get property by ID
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/properties/{propertyId}
```

#### Patch property
```bash
curl -s -X PATCH \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"name":"Elm Street Residences","address1":"123 Elm St","city":"Buffalo","state":"NY","postalCode":"14201"}' \
     http://localhost:8080/api/v1/properties/{propertyId}
```

#### Delete property (409 if any unit has active lease)
```bash
curl -s -w "\nHTTP: %{http_code}\n" -X DELETE \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/properties/{propertyId}
# 204 on success; 409 if any unit has active lease
```

### Phase B2: Units CRUD

#### Get unit by ID
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/units/{unitId}
```

#### Patch unit
```bash
curl -s -X PATCH \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"unitLabel":"Apt 102","status":"occupied"}' \
     http://localhost:8080/api/v1/units/{unitId}
```

#### Delete unit (409 if has active lease)
```bash
curl -s -w "\nHTTP: %{http_code}\n" -X DELETE \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/units/{unitId}
# 204 on success; 409 if unit has active lease
```

### Phase B2: Leases CRUD

#### List leases (optional filters: status, unitId)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/leases?page=0&size=20"

# With filters
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/leases?status=active&unitId={unitId}"
```

#### Get lease by ID
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/leases/{leaseId}
```

#### Patch lease (startDate, endDate only)
```bash
curl -s -X PATCH \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"startDate":"2025-01-01","endDate":"2026-01-31"}' \
     http://localhost:8080/api/v1/leases/{leaseId}
```

#### End lease (409 if already ended)
```bash
# With explicit endDate
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"endDate":"2025-06-30"}' \
     http://localhost:8080/api/v1/leases/{leaseId}/end

# Without body: uses today as endDate
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/leases/{leaseId}/end
# 200 on success; 409 if lease already ended
```

### Phase B3: Me + Membership Lists

#### Get current user (/me)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/me
# Returns accountId, userId, role; includes user.email, user.displayName if user exists in DB
```

#### Get unit members
```bash
# Landlord/pm: full access. Tenant: only if userId in members (403 otherwise)
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/units/{unitId}/members
# Returns [] until unit_members has rows (invite flow adds them)
```

#### Get lease tenants
```bash
# Landlord/pm: full access. Tenant: only if userId in tenants (403 otherwise)
# Always includes lease.tenantUserId; plus lease_tenants rows (deduped)
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/leases/{leaseId}/tenants
```

### Phase B4: Invites

#### Create invite (409 if unit has active lease)
```bash
# Unit must NOT have an active lease; landlord/pm only
curl -s -w "\nHTTP: %{http_code}\n" -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"contactType":"email","contactValue":"newtenant@example.com","role":"tenant"}' \
     http://localhost:8080/api/v1/units/{unitId}/invites
# 201 on success; 409 if unit has active lease
```

#### List invites for unit
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/units/{unitId}/invites?page=0&size=20"
```

#### Resend invite
```bash
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/invites/{inviteId}/resend
```

#### Cancel invite
```bash
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/invites/{inviteId}/cancel
```

#### Accept invite (uses inviteUrlToken from create response)
```bash
# Acceptor: principal.userId added to unit_members; requires dev auth
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     http://localhost:8080/api/v1/invites/accept/{inviteUrlToken}
# 409 if already accepted or expired
```

### Phase B5: Maintenance Tickets

#### Create ticket (as tenant – 403 if not in unit)
```bash
# Tenant: only for units they belong to (unit_members OR active lease). Landlord/pm: any unit.
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     -d '{"propertyId":"{propertyId}","unitId":"{unitId}","title":"Leaking faucet","description":"Kitchen sink drips","priority":"medium"}' \
     http://localhost:8080/api/v1/tickets
```

#### Create ticket (403 – tenant on unrelated unit)
```bash
# Replace {otherUnitId} with a unit the tenant is NOT part of
curl -s -w "\nHTTP: %{http_code}\n" -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     -d '{"propertyId":"{propertyId}","unitId":"{otherUnitId}","title":"Test","description":"","priority":"low"}' \
     http://localhost:8080/api/v1/tickets
# 403 Forbidden
```

#### Get ticket by ID
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/tickets/{ticketId}
```

#### List tickets (filter by unitId, status)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/tickets?unitId={unitId}&status=open&page=0&size=20"
```

#### Patch ticket
```bash
# Landlord/pm can set status, assignedContractorId. Tenant can set title, description, priority only.
curl -s -X PATCH \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"title":"Leaking faucet - urgent","priority":"high"}' \
     http://localhost:8080/api/v1/tickets/{ticketId}
```

#### Add comment
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     -d '{"body":"The leak got worse overnight."}' \
     http://localhost:8080/api/v1/tickets/{ticketId}/comments
```

#### Get comments
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/tickets/{ticketId}/comments
```

#### Assign (landlord only)
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"contractorId":"{contractorUuid}"}' \
     http://localhost:8080/api/v1/tickets/{ticketId}/assign
```

#### Close (landlord only)
```bash
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/tickets/{ticketId}/close
```

#### Reopen (landlord only, 409 if not closed)
```bash
curl -s -w "\nHTTP: %{http_code}\n" -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/tickets/{ticketId}/reopen
# 409 if ticket not closed
```

### Phase B6: Contractors + Assignments

#### Create contractor
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"name":"ABC Plumbing","email":"contact@abcplumbing.com","phone":"+15551234567","specialty":"plumbing"}' \
     http://localhost:8080/api/v1/contractors
```

#### Get contractor by ID
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/contractors/{contractorId}
```

#### Patch contractor
```bash
curl -s -X PATCH \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"status":"inactive"}' \
     http://localhost:8080/api/v1/contractors/{contractorId}
```

#### List contractors
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/contractors?status=active&page=0&size=20"
```

#### Create assignment (409 if ticket already has one)
```bash
curl -s -w "\nHTTP: %{http_code}\n" -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"ticketId":"{ticketId}","contractorId":"{contractorId}","notes":"Please schedule within 48h"}' \
     http://localhost:8080/api/v1/assignments
# 201 on success; 409 if ticket already has an assignment
```

#### Assign ticket via tickets endpoint (same as above, 409 on duplicate)
```bash
curl -s -w "\nHTTP: %{http_code}\n" -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"contractorId":"{contractorId}"}' \
     http://localhost:8080/api/v1/tickets/{ticketId}/assign
# 409 if ticket already assigned
```

#### List contractor assignments
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/contractors/{contractorId}/assignments
```

#### Patch assignment (status transitions)
```bash
curl -s -X PATCH \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"status":"accepted"}' \
     http://localhost:8080/api/v1/assignments/{assignmentId}
```

#### Complete assignment
```bash
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/assignments/{assignmentId}/complete
```

### Phase B7: Community Posts + Notifications

#### Create post (landlord/pm only)
```bash
# Account-wide post (propertyId and unitId omitted)
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"title":"Building maintenance Monday","body":"Water shutoff 9am-12pm for repairs.","kind":"announcement"}' \
     http://localhost:8080/api/v1/posts

# Property-specific post
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"propertyId":"{propertyId}","title":"Parking lot resurfacing","body":"Lot will be closed next week.","kind":"alert"}' \
     http://localhost:8080/api/v1/posts
```

#### List posts
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/posts?page=0&size=20"

# With filters (propertyId, unitId, kind)
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/posts?kind=announcement&page=0&size=20"
```

#### Get post by ID
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/posts/{postId}
```

#### Add comment
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     -d '{"body":"Thanks for the heads up!"}' \
     http://localhost:8080/api/v1/posts/{postId}/comments
```

#### Get comments
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/posts/{postId}/comments
```

#### React to post (upsert)
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     -d '{"reaction":"like"}' \
     http://localhost:8080/api/v1/posts/{postId}/reactions
# reaction: like | love | laugh | sad | angry
```

#### List notifications (current user)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     "http://localhost:8080/api/v1/notifications?page=0&size=20"
```

#### Mark notifications read (by IDs)
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     -d '{"notificationIds":["{id1}","{id2}"]}' \
     http://localhost:8080/api/v1/notifications/read
```

#### Mark all notifications read
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     -d '{"all":true}' \
     http://localhost:8080/api/v1/notifications/read
```

### Phase B8: Security Visitors + Approval

> **Note:** Security guard role can create visitor entries and list visitors within the account. Property assignment scoping (e.g. guard sees only assigned properties) is not implemented in B8.

#### Get security settings (landlord/pm/security_guard)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/properties/{propertyId}/security-settings
```

#### Set approval_required=true (landlord/pm only)
```bash
curl -s -X PATCH \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"approvalRequired":true}' \
     http://localhost:8080/api/v1/properties/{propertyId}/security-settings
```

#### Create visitor entry as security_guard (status=pending when approval_required=true)
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: security_guard" \
     -d '{"propertyId":"{propertyId}","visitorName":"John Doe","visitorPhone":"+15551234567","purpose":"Package delivery"}' \
     http://localhost:8080/api/v1/visitors
```

#### Approve visitor (landlord only, 409 if not pending)
```bash
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/visitors/{visitorId}/approve
```

#### Create visitor when approval_required=false (status=logged)
```bash
# First set approval_required=false (or use property with default settings)
curl -s -X PATCH \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"approvalRequired":false}' \
     http://localhost:8080/api/v1/properties/{propertyId}/security-settings

# Then create visitor – status=logged
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: security_guard" \
     -d '{"propertyId":"{propertyId}","visitorName":"Jane Smith","purpose":"Maintenance visit"}' \
     http://localhost:8080/api/v1/visitors
```

#### Deny visitor (landlord only)
```bash
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/visitors/{visitorId}/deny
# 409 if visitor entry not pending
```

#### List visitors (filter by propertyId, unitId, status)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/visitors?propertyId={propertyId}&status=pending&page=0&size=20"
```

### Phase B9: Ledger (Charges, Payments, Balances)

All ledger write endpoints **require** `Idempotency-Key` header. Use a UUID to prevent duplicate entries on retries.

#### Create charge (landlord) with Idempotency-Key
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "Idempotency-Key: 550e8400-e29b-41d4-a716-446655440099" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"unitId":"{unitId}","subtype":"rent","amountCents":150000,"occurredOn":"2025-01-01","memo":"January 2025 rent"}' \
     http://localhost:8080/api/v1/ledger/charges
```

#### Create payment (tenant) with Idempotency-Key
```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "Idempotency-Key: 660e8400-e29b-41d4-a716-446655440100" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     -d '{"unitId":"{unitId}","leaseId":"{leaseId}","amountCents":150000,"occurredOn":"2025-01-02","memo":"Rent payment"}' \
     http://localhost:8080/api/v1/ledger/payments
```

#### List ledger entries (by unit)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/ledger/units/{unitId}?from=2025-01-01&to=2025-01-31&page=0&size=20"
```

#### List ledger entries (by lease)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/ledger/leases/{leaseId}?page=0&size=20"
```

#### Get balance (unit)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/balances/units/{unitId}?asOf=2025-01-15"
```

#### Get balance (lease)
```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/balances/leases/{leaseId}"
```

#### 409 Idempotency conflict (same key, different payload)
```bash
# First request succeeds
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "Idempotency-Key: 770e8400-e29b-41d4-a716-446655440101" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"unitId":"{unitId}","subtype":"rent","amountCents":150000,"occurredOn":"2025-01-01"}' \
     http://localhost:8080/api/v1/ledger/charges

# Second request with SAME key but DIFFERENT amount -> 409
curl -s -w "\nHTTP: %{http_code}\n" -X POST \
     -H "Content-Type: application/json" \
     -H "Idempotency-Key: 770e8400-e29b-41d4-a716-446655440101" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"unitId":"{unitId}","subtype":"rent","amountCents":200000,"occurredOn":"2025-01-01"}' \
     http://localhost:8080/api/v1/ledger/charges
# 409 Conflict: Idempotency-Key reuse with different payload
```

#### 400 Missing Idempotency-Key
```bash
curl -s -w "\nHTTP: %{http_code}\n" -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     -d '{"unitId":"{unitId}","subtype":"rent","amountCents":150000,"occurredOn":"2025-01-01"}' \
     http://localhost:8080/api/v1/ledger/charges
# 400: Idempotency-Key is required
```

### Phase B10: Stripe Payments

#### Stripe configuration (env vars)

Set these before running when using Stripe:

```bash
export STRIPE_SECRET_KEY=sk_test_xxx
export STRIPE_WEBHOOK_SECRET=whsec_xxx
export STRIPE_SUCCESS_URL=https://your-app.com/payment/success
export STRIPE_CANCEL_URL=https://your-app.com/payment/cancel
```

- **STRIPE_SECRET_KEY**: Stripe API secret key (test/live)
- **STRIPE_WEBHOOK_SECRET**: Signing secret from Stripe Dashboard → Webhooks
- **STRIPE_SUCCESS_URL**: Where to redirect after successful payment
- **STRIPE_CANCEL_URL**: Where to redirect if user cancels

#### Create Checkout Session (with dev headers)

```bash
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     -d '{"unitId":"{unitId}","leaseId":"{leaseId}","amountCents":150000}' \
     http://localhost:8080/api/v1/payments/stripe/checkout-session
# Returns: { "checkoutSessionId": "...", "checkoutUrl": "https://checkout.stripe.com/..." }
```

#### List payment history

```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/payments/history?unitId={unitId}&page=0&size=20"
```

#### Webhook (Stripe CLI)

The webhook endpoint is public (no dev auth) but requires valid `Stripe-Signature`. Test locally with Stripe CLI:

```bash
# Install Stripe CLI: https://stripe.com/docs/stripe-cli
stripe login
stripe listen --forward-to localhost:8080/api/v1/payments/stripe/webhook
# Use the webhook signing secret (whsec_...) from the listen output in STRIPE_WEBHOOK_SECRET
```

### Phase B11: Tenant Transfer Profile

Tenant can export a shareable profile token; new landlord views (redacted), requests consent; tenant approves/rejects; landlord can import full summary after approval.

#### 1. Tenant: Get my profile
```bash
# Any authenticated user; tenant-like recommended for full flow
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     http://localhost:8080/api/v1/tenant-profile/me
# Returns: profile, ratingAvg, ratingCount, recentReviews
```

#### 2. Tenant: Export share token
```bash
# Tenant-like role only; creates export with 30-day expiry
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     http://localhost:8080/api/v1/tenant-profile/me/export
# Returns: { "exportId": "...", "shareToken": "...", "expiresAt": "...", "shareUrl": "/api/v1/tenant-profile/share/{shareToken}" }
# Save shareToken for next steps
```

#### 3. Landlord: View redacted (before approval)
```bash
# Landlord/pm views via share URL; gets redacted view: displayName + rating aggregate only
curl -s -H "X-Dev-AccountId: cccccccc-0000-0000-0000-000000000002" \
     -H "X-Dev-UserId: dddddddd-0000-0000-0000-000000000002" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/tenant-profile/share/{shareToken}"
# Returns: tenantUserId, displayName, ratingAvg, ratingCount, fullAccess=false (no phone/email/address/reviews)
```

#### 4. Landlord: Request review
```bash
# Landlord/pm creates pending transfer request; 409 if already pending for same account
curl -s -X POST \
     -H "X-Dev-AccountId: cccccccc-0000-0000-0000-000000000002" \
     -H "X-Dev-UserId: dddddddd-0000-0000-0000-000000000002" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/tenant-profile/share/{shareToken}/request-review"
# Returns: { "id": "...", "exportId": "...", "status": "pending", ... }
# Save requestId for tenant to approve
```

#### 5. Tenant: Approve request
```bash
# Tenant (owner of export) approves; must use tenant user headers
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     "http://localhost:8080/api/v1/tenant-profile/requests/{requestId}/approve"
# Returns: { "id": "...", "status": "approved", ... }
```

#### 6. Landlord: View full (after approval)
```bash
# Same share URL; now returns full profile + reviews
curl -s -H "X-Dev-AccountId: cccccccc-0000-0000-0000-000000000002" \
     -H "X-Dev-UserId: dddddddd-0000-0000-0000-000000000002" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/tenant-profile/share/{shareToken}"
# Returns: fullAccess=true, about, phone, email, lastKnownAddress, reviews
```

#### 7. Landlord: Import summary
```bash
# Only allowed if approved request exists for caller's account
curl -s -X POST \
     -H "X-Dev-AccountId: cccccccc-0000-0000-0000-000000000002" \
     -H "X-Dev-UserId: dddddddd-0000-0000-0000-000000000002" \
     -H "X-Dev-Role: landlord" \
     "http://localhost:8080/api/v1/tenant-profile/share/{shareToken}/import"
# Returns: { "tenantUserId", "displayName", "ratingAvg", "ratingCount", "reviews": [...] }
# 409 if no approved request
```

#### 8. Tenant: Revoke export
```bash
# Tenant revokes their export; sets status=revoked
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     "http://localhost:8080/api/v1/tenant-profile/me/exports/{exportId}/revoke"
# 204 No Content
```

#### 9. Tenant: Reject request (alternative to approve)
```bash
curl -s -X POST \
     -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: tenant" \
     "http://localhost:8080/api/v1/tenant-profile/requests/{requestId}/reject"
# Returns: { "id": "...", "status": "rejected", ... }
```

## API Docs

- Swagger UI: http://localhost:8080/swagger-ui.html
- OpenAPI JSON: http://localhost:8080/api/docs

## Actuator

- Health: http://localhost:8080/actuator/health
- Info: http://localhost:8080/actuator/info
