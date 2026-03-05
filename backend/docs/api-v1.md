# AYRNOW API Master Spec (v1)

**Version:** 1.0  
**Base URL:** `/api/v1`  
**Content-Type:** `application/json`

---

## 1. Authentication

### Current: Dev Headers

All protected endpoints require:

| Header | Type | Description |
|--------|------|-------------|
| `X-Dev-AccountId` | UUID | Account ID (must exist and match scoping) |
| `X-Dev-UserId` | UUID | User ID (must exist in account) |
| `X-Dev-Role` | String | Role: `owner`, `landlord`, `manager`, `tenant`, `family`, `coTenant`, `contractor`, `security_guard` |

Missing or invalid headers → `401 Unauthorized`.

**Public endpoints** (no auth): `/api/v1/health`, `/actuator/health`, `/swagger-ui/**`, `/v3/api-docs/**`

### Future Auth

JWT will replace dev headers. Endpoint paths, request/response shapes, and account scoping rules will remain unchanged. Client must send `Authorization: Bearer <token>` instead of dev headers.

---

## 2. Account Scoping

Every query is filtered by `accountId` from the authenticated principal. Cross-account access is never permitted. Resources returned are guaranteed to belong to the caller's account.

---

## 3. Standard Error Envelope

All error responses use this JSON structure:

```json
{
  "error": "error_code",
  "message": "Human-readable message",
  "fields": {
    "fieldName": "field-specific validation message"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `error` | string | Error code (e.g. `validation_error`, `not_found`, `unauthorized`) |
| `message` | string | Human-readable message |
| `fields` | object \| null | Optional; present for `validation_error` |

### Common Error Codes

| HTTP Status | `error` | When |
|-------------|---------|------|
| 400 | `validation_error` | Request validation failed (fields present) |
| 400 | `bad_request` | Business rule violation (e.g. unit already has active lease) |
| 401 | `unauthorized` | Missing or invalid auth |
| 403 | `forbidden` | Valid auth but insufficient role |
| 404 | `not_found` | Resource does not exist or not in account |
| 500 | `internal_error` | Unexpected server error |

---

## 4. Pagination

**Convention:** Page/size (offset-based)

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | int | 0 | Zero-based page index |
| `size` | int | 20 | Page size (max 100) |

**Response wrapper** for paginated list endpoints:

```json
{
  "content": [ ... ],
  "page": 0,
  "size": 20,
  "totalElements": 42,
  "totalPages": 3,
  "first": true,
  "last": false
}
```

**When to use pagination:** List endpoints that can return large result sets (leases, tickets, contractors, posts, visitor log, ledger charges/payments) use this wrapper. Small bounded lists (e.g. properties, units per property) may return plain arrays for simplicity.

---

## 5. Common Status Enums

| Enum | Values | Description |
|------|--------|-------------|
| `unit_status` | `vacant`, `occupied`, `maintenance`, `reserved` | Unit availability/occupancy |
| `lease_status` | `active`, `ended`, `cancelled` | Lease lifecycle |
| `ticket_status` | `open`, `assigned`, `in_progress`, `closed`, `reopened` | Maintenance ticket workflow |
| `assignment_status` | `pending`, `accepted`, `declined`, `completed` | Contractor assignment state |

| Enum Value | Meaning |
|------------|---------|
| `unit_status.vacant` | Available for new lease |
| `unit_status.occupied` | Currently leased |
| `unit_status.maintenance` | Under repair or prep |
| `unit_status.reserved` | Reserved, not yet occupied |
| `lease_status.active` | Current, in effect |
| `lease_status.ended` | Terminated normally |
| `lease_status.cancelled` | Cancelled before end |
| `ticket_status.open` | New, unassigned |
| `ticket_status.assigned` | Assigned to contractor |
| `ticket_status.in_progress` | Work started |
| `ticket_status.closed` | Resolved |
| `ticket_status.reopened` | Reopened after close |
| `assignment_status.pending` | Awaiting contractor response |
| `assignment_status.accepted` | Contractor accepted |
| `assignment_status.declined` | Contractor declined |
| `assignment_status.completed` | Work completed |

---

## 5b. Role Access Matrix

Roles: **landlord** (LL), **tenant** (T), **pm** (property manager), **contractor** (C), **security_guard** (SG).

| Domain | Endpoint Group | LL | T | pm | C | SG |
|--------|----------------|----|---|----|---|-----|
| **System** | /health | ✓ (public) | ✓ | ✓ | ✓ | ✓ |
| | /me | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Properties** | List, Create, Get, Patch, Delete | ✓ | — | ✓ | — | — |
| **Units** | List, Create, Get, Patch, Delete, Members | ✓ | own unit | ✓ | — | — |
| **Invites** | Create, Resend, Cancel | ✓ | — | ✓ | — | — |
| | Accept | ✓ | ✓ (invitee) | ✓ | ✓ (invitee) | ✓ (invitee) |
| **Leases** | List, Create, Get, Patch, End | ✓ | — | ✓ | — | — |
| | /leases/me/active | — | ✓ | — | — | — |
| | /leases/{id}/tenants | ✓ | own | ✓ | — | — |
| **Maintenance** | List, Create, Get, Patch, Comments | ✓ | own | ✓ | — | — |
| | Assign, Close, Reopen | ✓ | — | ✓ | — | — |
| **Contractors** | List, Create, Get, Patch, Delete | ✓ | — | ✓ | — | — |
| | Assignments list | ✓ | — | ✓ | ✓ (own) | — |
| | Accept, Decline, Complete | — | — | — | ✓ | — |
| **Community** | Posts, Comments, Reactions, Notifications | ✓ | ✓ | ✓ | — | — |
| **Security Guard** | Visitor log (list, create) | ✓ | — | ✓ | — | ✓ |
| | Approve, Deny | — | — | — | — | ✓ |
| | Property security settings | ✓ | — | ✓ | — | ✓ |
| **Ledger** | Charges, Payments, Refunds, Balances | ✓ | own unit | ✓ | — | — |
| **Payments** | SetupIntent, PaymentIntent, Methods | ✓ | own | ✓ | — | — |
| **Tenant Transfer** | Export, Import | ✓ | — | ✓ | — | — |

---

## 5c. Idempotency (Payments & Ledger)

For **payments** and **ledger** write endpoints, clients MUST send `Idempotency-Key` to ensure safe retries.

| Header | Type | Description |
|--------|------|-------------|
| `Idempotency-Key` | string | Client-generated UUID; unique per logical operation |

**Rules:**
- **Required** for: `POST /ledger/charges`, `POST /ledger/payments`, `POST /ledger/refunds`, `POST /payments/setup-intent`, `POST /payments/payment-intent`
- Same key within 24h → return original response (201/200) without replaying operation
- Different key → treat as new operation
- Missing key on required endpoints → `400 bad_request` with `"Idempotency-Key is required"`

**Example:**
```http
POST /api/v1/ledger/payments
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440099
Content-Type: application/json

{"leaseId": "...", "amount": 150000, "paymentMethodId": "...", "reference": "rent-jan-2025"}
```

---

## 6. Endpoint Reference

### 6.1 System

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| GET | `/health` | Liveness check (no auth) | — |
| GET | `/me` | Current user profile | all |

#### GET /health
**Auth:** None

**Response 200:**
```json
{
  "status": "ok"
}
```

---

#### GET /me
**Auth:** Required

**Headers:** `X-Dev-AccountId`, `X-Dev-UserId`, `X-Dev-Role`

**Response 200:**
```json
{
  "id": "bbbbbbbb-0000-0000-0000-000000000001",
  "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
  "email": "dev@example.com",
  "displayName": "Dev User",
  "role": "landlord",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

**Errors:** 401, 404

---

### 6.2 Properties

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| GET | `/properties` | List properties | owner, landlord, manager |
| POST | `/properties` | Create property | owner, landlord, manager |
| GET | `/properties/{id}` | Get property by ID | owner, landlord, manager |
| PATCH | `/properties/{id}` | Update property | owner, landlord, manager |
| DELETE | `/properties/{id}` | Delete property (cascade rules) | owner, landlord |

#### GET /properties
**Auth:** Required

**Response 200:**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
    "name": "Elm Street Apartments",
    "address1": "123 Elm St",
    "city": "Buffalo",
    "state": "NY",
    "postalCode": "14201",
    "createdAt": "2025-01-01T00:00:00Z"
  }
]
```

---

#### POST /properties
**Auth:** Required

**Request:**
```json
{
  "name": "Elm Street Apartments",
  "address1": "123 Elm St",
  "city": "Buffalo",
  "state": "NY",
  "postalCode": "14201"
}
```

**Response 201:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
  "name": "Elm Street Apartments",
  "address1": "123 Elm St",
  "city": "Buffalo",
  "state": "NY",
  "postalCode": "14201",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

**Errors:** 400 (validation), 401

---

#### GET /properties/{id}
**Auth:** Required

**Response 200:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
  "name": "Elm Street Apartments",
  "address1": "123 Elm St",
  "city": "Buffalo",
  "state": "NY",
  "postalCode": "14201",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

**Errors:** 401, 404

---

#### PATCH /properties/{id}
**Auth:** Required

**Request:**
```json
{
  "name": "Elm Street Residences",
  "address1": "123 Elm St",
  "city": "Buffalo",
  "state": "NY",
  "postalCode": "14201"
}
```
All fields optional; only provided fields updated.

**Response 200:** Same shape as GET

**Errors:** 400, 401, 404

---

#### DELETE /properties/{id}
**Auth:** Required

**Response 204:** No content

**Errors:** 400 (has units/leases), 401, 404

---

### 6.3 Units

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| GET | `/properties/{propertyId}/units` | List units by property | owner, landlord, manager |
| POST | `/properties/{propertyId}/units` | Create unit | owner, landlord, manager |
| GET | `/units/{id}` | Get unit by ID | owner, landlord, manager, tenant (own unit) |
| PATCH | `/units/{id}` | Update unit | owner, landlord, manager |
| DELETE | `/units/{id}` | Delete unit | owner, landlord, manager |
| GET | `/units/{id}/members` | List unit members (tenants, etc.) | owner, landlord, manager, tenant (own unit) |

#### GET /properties/{propertyId}/units
**Auth:** Required

**Response 200:**
```json
[
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
    "propertyId": "550e8400-e29b-41d4-a716-446655440000",
    "unitLabel": "Apt 101",
    "status": "vacant",
    "createdAt": "2025-01-01T00:00:00Z"
  }
]
```

---

#### POST /properties/{propertyId}/units
**Auth:** Required

**Request:**
```json
{
  "unitLabel": "Apt 101",
  "status": "vacant"
}
```
`status` optional; defaults to `vacant` if null/blank.

**Response 201:**
```json
{
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
  "propertyId": "550e8400-e29b-41d4-a716-446655440000",
  "unitLabel": "Apt 101",
  "status": "vacant",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

**Errors:** 400 (validation), 401, 404 (property)

---

#### GET /units/{id}
**Auth:** Required

**Response 200:** Same shape as unit in list above

**Errors:** 401, 404

---

#### PATCH /units/{id}
**Auth:** Required

**Request:**
```json
{
  "unitLabel": "Apt 102",
  "status": "occupied"
}
```
All fields optional.

**Response 200:** Same shape as GET

**Errors:** 400, 401, 404

---

#### DELETE /units/{id}
**Auth:** Required

**Response 204:** No content

**Errors:** 400 (has active lease), 401, 404

---

#### GET /units/{id}/members
**Auth:** Required

**Response 200:**
```json
[
  {
    "userId": "bbbbbbbb-0000-0000-0000-000000000001",
    "role": "tenant",
    "leaseId": "770e8400-e29b-41d4-a716-446655440002",
    "startDate": "2025-01-01",
    "endDate": "2025-12-31"
  }
]
```

**Errors:** 401, 404

---

### 6.4 Invites

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| POST | `/invites` | Create invite (email, role, property/unit) | owner, landlord, manager |
| POST | `/invites/{id}/resend` | Resend invite email | owner, landlord, manager |
| DELETE | `/invites/{id}` | Cancel invite | owner, landlord, manager |
| POST | `/invites/{id}/accept` | Accept invite (creates membership) | invitee |

#### POST /invites
**Auth:** Required

**Request:**
```json
{
  "email": "newtenant@example.com",
  "role": "tenant",
  "propertyId": "550e8400-e29b-41d4-a716-446655440000",
  "unitId": "660e8400-e29b-41d4-a716-446655440001",
  "expiresAt": "2025-02-01T00:00:00Z"
}
```

**Response 201:**
```json
{
  "id": "880e8400-e29b-41d4-a716-446655440003",
  "email": "newtenant@example.com",
  "role": "tenant",
  "status": "pending",
  "expiresAt": "2025-02-01T00:00:00Z",
  "createdAt": "2025-01-15T00:00:00Z"
}
```

---

#### POST /invites/{id}/resend
**Auth:** Required

**Response 200:**
```json
{
  "id": "880e8400-e29b-41d4-a716-446655440003",
  "status": "resent",
  "expiresAt": "2025-02-15T00:00:00Z"
}
```

---

#### DELETE /invites/{id}
**Auth:** Required

**Response 204:** No content

---

#### POST /invites/{id}/accept
**Auth:** Required (invitee user)

**Request:**
```json
{
  "acceptTerms": true
}
```

**Response 200:**
```json
{
  "membershipId": "990e8400-e29b-41d4-a716-446655440004",
  "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
  "role": "tenant",
  "status": "active"
}
```

---

### 6.5 Leases

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| GET | `/leases` | List leases (filterable) | owner, landlord, manager |
| POST | `/leases` | Create lease | owner, landlord, manager |
| GET | `/leases/{id}` | Get lease by ID | owner, landlord, manager, tenant (own) |
| PATCH | `/leases/{id}` | Update lease | owner, landlord, manager |
| POST | `/leases/{id}/end` | End lease | owner, landlord, manager |
| GET | `/leases/me/active` | Get my active lease | tenant, family, coTenant |
| GET | `/leases/{id}/tenants` | List lease tenants | owner, landlord, manager, tenant (own) |

**Constraint:** Only one `active` lease per unit. Create returns 400 if unit already has active lease.

#### GET /leases
**Auth:** Required

**Query:** `?propertyId=`, `?unitId=`, `?status=`, `?page=`, `?size=`

**Response 200:**
```json
{
  "content": [
    {
      "id": "770e8400-e29b-41d4-a716-446655440002",
      "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
      "unitId": "660e8400-e29b-41d4-a716-446655440001",
      "status": "active",
      "startDate": "2025-01-01",
      "endDate": "2025-12-31",
      "tenantUserId": "bbbbbbbb-0000-0000-0000-000000000001",
      "createdAt": "2025-01-01T00:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true
}
```

---

#### POST /leases
**Auth:** Required

**Request:**
```json
{
  "unitId": "660e8400-e29b-41d4-a716-446655440001",
  "tenantUserId": "bbbbbbbb-0000-0000-0000-000000000001",
  "startDate": "2025-01-01",
  "endDate": "2025-12-31"
}
```
`endDate` optional.

**Response 201:**
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440002",
  "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
  "unitId": "660e8400-e29b-41d4-a716-446655440001",
  "status": "active",
  "startDate": "2025-01-01",
  "endDate": "2025-12-31",
  "tenantUserId": "bbbbbbbb-0000-0000-0000-000000000001",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

**Errors:** 400 (validation, unit has active lease), 401, 404

---

#### GET /leases/{id}
**Auth:** Required

**Response 200:** Same shape as lease in list

---

#### PATCH /leases/{id}
**Auth:** Required

**Request:**
```json
{
  "endDate": "2026-01-31",
  "status": "active"
}
```

**Response 200:** Same shape as GET

---

#### POST /leases/{id}/end
**Auth:** Required

**Request:**
```json
{
  "endDate": "2025-06-30",
  "reason": "tenant_move_out"
}
```

**Response 200:**
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440002",
  "status": "ended",
  "endDate": "2025-06-30"
}
```

---

#### GET /leases/me/active
**Auth:** Required (tenant role)

**Response 200:** Same shape as lease in list

**Errors:** 401, 404 (no active lease)

---

#### GET /leases/{id}/tenants
**Auth:** Required

**Response 200:**
```json
[
  {
    "userId": "bbbbbbbb-0000-0000-0000-000000000001",
    "role": "tenant",
    "displayName": "John Doe",
    "email": "john@example.com"
  }
]
```

---

### 6.6 Maintenance (Tickets)

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| GET | `/maintenance/tickets` | List tickets (filterable) | owner, landlord, manager, tenant |
| POST | `/maintenance/tickets` | Create ticket | tenant, landlord, manager |
| GET | `/maintenance/tickets/{id}` | Get ticket | owner, landlord, manager, tenant (own) |
| PATCH | `/maintenance/tickets/{id}` | Update ticket | owner, landlord, manager |
| POST | `/maintenance/tickets/{id}/comments` | Add comment | owner, landlord, manager, tenant (own) |
| POST | `/maintenance/tickets/{id}/assign` | Assign to contractor | owner, landlord, manager |
| POST | `/maintenance/tickets/{id}/close` | Close ticket | owner, landlord, manager |
| POST | `/maintenance/tickets/{id}/reopen` | Reopen ticket | owner, landlord, manager |

#### GET /maintenance/tickets
**Auth:** Required

**Query:** `?unitId=`, `?status=`, `?propertyId=`, `?page=`, `?size=`

**Response 200:**
```json
{
  "content": [
    {
      "id": "aa0e8400-e29b-41d4-a716-446655440010",
      "unitId": "660e8400-e29b-41d4-a716-446655440001",
      "title": "Leaking faucet",
      "description": "Kitchen sink drips constantly",
      "status": "open",
      "priority": "medium",
      "category": "plumbing",
      "createdBy": "bbbbbbbb-0000-0000-0000-000000000001",
      "createdAt": "2025-01-15T00:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true
}
```

---

#### POST /maintenance/tickets
**Request:**
```json
{
  "unitId": "660e8400-e29b-41d4-a716-446655440001",
  "title": "Leaking faucet",
  "description": "Kitchen sink drips constantly",
  "priority": "medium",
  "category": "plumbing"
}
```

**Response 201:**
```json
{
  "id": "aa0e8400-e29b-41d4-a716-446655440010",
  "unitId": "660e8400-e29b-41d4-a716-446655440001",
  "title": "Leaking faucet",
  "status": "open",
  "priority": "medium",
  "createdBy": "bbbbbbbb-0000-0000-0000-000000000001",
  "createdAt": "2025-01-15T00:00:00Z"
}
```

---

#### POST /maintenance/tickets/{id}/comments
**Request:**
```json
{
  "body": "Tenant says the leak worsened overnight."
}
```

**Response 201:**
```json
{
  "id": "ab0e8400-e29b-41d4-a716-446655440011",
  "ticketId": "aa0e8400-e29b-41d4-a716-446655440010",
  "body": "Tenant says the leak worsened overnight.",
  "authorId": "bbbbbbbb-0000-0000-0000-000000000001",
  "createdAt": "2025-01-16T00:00:00Z"
}
```

---

#### POST /maintenance/tickets/{id}/assign
**Request:**
```json
{
  "contractorId": "cc0e8400-e29b-41d4-a716-446655440020",
  "scheduledAt": "2025-01-20T09:00:00Z"
}
```

**Response 200:**
```json
{
  "ticketId": "aa0e8400-e29b-41d4-a716-446655440010",
  "status": "assigned",
  "assignmentStatus": "pending",
  "contractorId": "cc0e8400-e29b-41d4-a716-446655440020"
}
```

---

### 6.7 Contractors

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| GET | `/contractors` | List contractors | owner, landlord, manager |
| POST | `/contractors` | Create contractor | owner, landlord, manager |
| GET | `/contractors/{id}` | Get contractor | owner, landlord, manager |
| PATCH | `/contractors/{id}` | Update contractor | owner, landlord, manager |
| DELETE | `/contractors/{id}` | Delete contractor | owner, landlord, manager |
| GET | `/contractors/{id}/assignments` | List assignments | owner, landlord, manager, contractor |
| POST | `/contractors/assignments/{id}/accept` | Accept assignment | contractor |
| POST | `/contractors/assignments/{id}/decline` | Decline assignment | contractor |
| POST | `/contractors/assignments/{id}/complete` | Mark completed | contractor |

#### GET /contractors
**Auth:** Required

**Query:** `?propertyId=`, `?trade=`, `?page=`, `?size=`

**Response 200:**
```json
{
  "content": [
    {
      "id": "cc0e8400-e29b-41d4-a716-446655440020",
      "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
      "name": "ABC Plumbing",
      "email": "contact@abcplumbing.com",
      "phone": "+15551234567",
      "trade": "plumbing",
      "status": "active",
      "createdAt": "2025-01-01T00:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true
}
```

---

#### POST /contractors
**Request:**
```json
{
  "name": "ABC Plumbing",
  "email": "contact@abcplumbing.com",
  "phone": "+15551234567",
  "trade": "plumbing",
  "properties": ["550e8400-e29b-41d4-a716-446655440000"]
}
```

**Response 201:**
```json
{
  "id": "cc0e8400-e29b-41d4-a716-446655440020",
  "accountId": "aaaaaaaa-0000-0000-0000-000000000001",
  "name": "ABC Plumbing",
  "email": "contact@abcplumbing.com",
  "trade": "plumbing",
  "status": "active",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

---

### 6.8 Community

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| GET | `/community/posts` | List posts (paginated) | owner, landlord, manager, tenant |
| POST | `/community/posts` | Create post | owner, landlord, manager, tenant |
| GET | `/community/posts/{id}` | Get post | all |
| PATCH | `/community/posts/{id}` | Update post | author |
| DELETE | `/community/posts/{id}` | Delete post | author, landlord |
| POST | `/community/posts/{id}/comments` | Add comment | owner, landlord, manager, tenant |
| POST | `/community/posts/{id}/reactions` | Add/toggle reaction | owner, landlord, manager, tenant |
| GET | `/community/notifications` | List notifications | all |

#### GET /community/posts
**Auth:** Required

**Query:** `?propertyId=`, `?page=`, `?size=`

**Response 200:**
```json
{
  "content": [
    {
      "id": "dd0e8400-e29b-41d4-a716-446655440030",
      "propertyId": "550e8400-e29b-41d4-a716-446655440000",
      "authorId": "bbbbbbbb-0000-0000-0000-000000000001",
      "title": "Pool hours update",
      "body": "Pool will close at 8pm starting next week.",
      "visibility": "property",
      "commentCount": 3,
      "createdAt": "2025-01-15T00:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true
}
```

---

#### POST /community/posts
**Request:**
```json
{
  "propertyId": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Pool hours update",
  "body": "Pool will close at 8pm starting next week.",
  "visibility": "property"
}
```

**Response 201:**
```json
{
  "id": "dd0e8400-e29b-41d4-a716-446655440030",
  "propertyId": "550e8400-e29b-41d4-a716-446655440000",
  "authorId": "bbbbbbbb-0000-0000-0000-000000000001",
  "title": "Pool hours update",
  "body": "Pool will close at 8pm starting next week.",
  "visibility": "property",
  "createdAt": "2025-01-15T00:00:00Z"
}
```

---

### 6.9 Security Guard

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| GET | `/security/visitor-log` | List visitor entries (filterable) | security_guard, landlord, manager |
| POST | `/security/visitor-log` | Log visitor entry | security_guard |
| POST | `/security/visitor-log/{id}/approve` | Approve visitor | security_guard |
| POST | `/security/visitor-log/{id}/deny` | Deny visitor | security_guard |
| GET | `/security/properties/{propertyId}/settings` | Get property security settings | security_guard, landlord, manager |
| PATCH | `/security/properties/{propertyId}/settings` | Update security settings | landlord, manager |

#### GET /security/visitor-log
**Auth:** Required

**Query:** `?propertyId=`, `?unitId=`, `?status=`, `?fromDate=`, `?toDate=`, `?page=`, `?size=`

**Response 200:**
```json
{
  "content": [
    {
      "id": "ee0e8400-e29b-41d4-a716-446655440040",
      "propertyId": "550e8400-e29b-41d4-a716-446655440000",
      "visitorName": "Jane Smith",
      "visitorPhone": "+15559876543",
      "unitId": "660e8400-e29b-41d4-a716-446655440001",
      "status": "pending",
      "expectedAt": "2025-01-20T14:00:00Z",
      "createdAt": "2025-01-20T13:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true
}
```

---

#### POST /security/visitor-log
**Request:**
```json
{
  "propertyId": "550e8400-e29b-41d4-a716-446655440000",
  "visitorName": "Jane Smith",
  "visitorPhone": "+15559876543",
  "unitId": "660e8400-e29b-41d4-a716-446655440001",
  "expectedAt": "2025-01-20T14:00:00Z",
  "notes": "Delivery"
}
```

**Response 201:**
```json
{
  "id": "ee0e8400-e29b-41d4-a716-446655440040",
  "propertyId": "550e8400-e29b-41d4-a716-446655440000",
  "visitorName": "Jane Smith",
  "status": "pending",
  "expectedAt": "2025-01-20T14:00:00Z",
  "createdAt": "2025-01-20T13:00:00Z"
}
```

---

### 6.10 Ledger (planned)

Ledger-first design: charges, payments, refunds, balances. All financial records immutable; corrections via adjustment entries. **Idempotency-Key required** for write endpoints (see §5c).

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| GET | `/ledger/charges` | List charges (unit, lease, date range) | landlord, pm, tenant (own) |
| POST | `/ledger/charges` | Create charge | landlord, pm |
| GET | `/ledger/payments` | List payments | landlord, pm, tenant (own) |
| POST | `/ledger/payments` | Record payment | landlord, pm, tenant (own) |
| POST | `/ledger/refunds` | Create refund | landlord, pm |
| GET | `/ledger/balances` | Get balance by unit/lease/account | landlord, pm, tenant (own) |

#### GET /ledger/charges
**Query:** `?unitId=`, `?leaseId=`, `?fromDate=`, `?toDate=`, `?page=`, `?size=`

**Response 200:**
```json
{
  "content": [
    {
      "id": "ff0e8400-e29b-41d4-a716-446655440050",
      "leaseId": "770e8400-e29b-41d4-a716-446655440002",
      "type": "rent",
      "amount": 150000,
      "dueDate": "2025-01-01",
      "status": "posted",
      "description": "January 2025 rent",
      "createdAt": "2024-12-15T00:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true
}
```

#### POST /ledger/charges
**Headers:** `Idempotency-Key` (required)

**Request:**
```json
{
  "leaseId": "770e8400-e29b-41d4-a716-446655440002",
  "type": "rent",
  "amount": 150000,
  "dueDate": "2025-01-01",
  "description": "January 2025 rent"
}
```

**Response 201:**
```json
{
  "id": "ff0e8400-e29b-41d4-a716-446655440050",
  "leaseId": "770e8400-e29b-41d4-a716-446655440002",
  "type": "rent",
  "amount": 150000,
  "dueDate": "2025-01-01",
  "status": "posted",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

#### POST /ledger/payments
**Headers:** `Idempotency-Key` (required)

**Request:**
```json
{
  "leaseId": "770e8400-e29b-41d4-a716-446655440002",
  "amount": 150000,
  "paymentMethodId": "pm_xxx",
  "reference": "rent-jan-2025",
  "paidAt": "2025-01-02T10:00:00Z"
}
```

**Response 201:**
```json
{
  "id": "010e8400-e29b-41d4-a716-446655440051",
  "leaseId": "770e8400-e29b-41d4-a716-446655440002",
  "amount": 150000,
  "status": "succeeded",
  "reference": "rent-jan-2025",
  "createdAt": "2025-01-02T10:00:00Z"
}
```

#### GET /ledger/balances
**Query:** `?unitId=`, `?leaseId=`

**Response 200:**
```json
{
  "leaseId": "770e8400-e29b-41d4-a716-446655440002",
  "totalCharges": 150000,
  "totalPayments": 150000,
  "balance": 0,
  "currency": "USD",
  "asOf": "2025-01-15T00:00:00Z"
}
```

---

### 6.11 Payments / Stripe (planned)

Stripe integration for rent payments, deposits, and online payments. **Idempotency-Key required** for write endpoints (see §5c).

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| POST | `/payments/setup-intent` | Create SetupIntent for saved payment method | landlord, pm, tenant |
| POST | `/payments/payment-intent` | Create PaymentIntent for charge | landlord, pm, tenant |
| GET | `/payments/methods` | List saved payment methods | landlord, pm, tenant |
| DELETE | `/payments/methods/{id}` | Remove payment method | landlord, pm, tenant |

#### POST /payments/setup-intent
**Headers:** `Idempotency-Key` (required)

**Request:**
```json
{
  "returnUrl": "https://app.ayrnow.com/payments/complete"
}
```

**Response 201:**
```json
{
  "clientSecret": "seti_xxx_secret_xxx",
  "status": "requires_payment_method",
  "id": "seti_xxx"
}
```

#### POST /payments/payment-intent
**Headers:** `Idempotency-Key` (required)

**Request:**
```json
{
  "leaseId": "770e8400-e29b-41d4-a716-446655440002",
  "amount": 150000,
  "paymentMethodId": "pm_xxx",
  "reference": "rent-jan-2025"
}
```

**Response 201:**
```json
{
  "clientSecret": "pi_xxx_secret_xxx",
  "status": "requires_confirmation",
  "id": "pi_xxx",
  "amount": 150000
}
```

#### GET /payments/methods
**Auth:** Required

**Response 200:**
```json
[
  {
    "id": "pm_xxx",
    "brand": "visa",
    "last4": "4242",
    "expMonth": 12,
    "expYear": 2026,
    "isDefault": true
  }
]
```

---

### 6.12 Tenant Transfer Profile (planned)

Export/import tenant profile for move-out/move-in between properties or accounts.

| Method | Path | Purpose | Roles |
|--------|------|---------|-------|
| GET | `/tenants/{userId}/transfer-profile` | Export tenant profile | landlord, pm |
| POST | `/tenants/transfer-profile` | Import tenant profile | landlord, pm |

#### GET /tenants/{userId}/transfer-profile
**Response 200:**
```json
{
  "userId": "bbbbbbbb-0000-0000-0000-000000000001",
  "displayName": "John Doe",
  "email": "john@example.com",
  "phone": "+15551234567",
  "leaseHistory": [
    {
      "leaseId": "770e8400-e29b-41d4-a716-446655440002",
      "unitId": "660e8400-e29b-41d4-a716-446655440001",
      "startDate": "2024-01-01",
      "endDate": "2024-12-31",
      "status": "ended"
    }
  ],
  "exportedAt": "2025-01-15T00:00:00Z"
}
```

#### POST /tenants/transfer-profile
**Request:**
```json
{
  "profile": { ... },
  "targetAccountId": "aaaaaaaa-0000-0000-0000-000000000002",
  "targetUnitId": "660e8400-e29b-41d4-a716-446655440010"
}
```

**Response 201:**
```json
{
  "userId": "cccccccc-0000-0000-0000-000000000001",
  "leaseId": "770e8400-e29b-41d4-a716-446655440099",
  "status": "imported"
}
```

---

## 7. Implementation Milestones

| Phase | Scope |
|-------|-------|
| **B0** | Health, properties list/create, units list, leases/me/active |
| **B1** | POST units, POST leases, one-active-lease-per-unit, security allowlist |
| **B2** | GET/PATCH/DELETE properties, GET/PATCH/DELETE units, GET leases list, GET leases/{id}, PATCH leases, POST leases/{id}/end |
| **B3** | GET /me, unit members, lease tenants |
| **B4** | Invites (create/resend/cancel/accept) |
| **B5** | Maintenance tickets CRUD, comments, assign/close/reopen |
| **B6** | Contractors CRUD, assignments |
| **B7** | Community (posts, comments, reactions, notifications) |
| **B8** | Security Guard (visitor log, approve/deny, property settings) |
| **B9** | Ledger (charges, payments, refunds, balances) |
| **B10** | Payments/Stripe integration |
| **B11** | Tenant transfer profile |

---

*Document last updated: 2025-02-15*
