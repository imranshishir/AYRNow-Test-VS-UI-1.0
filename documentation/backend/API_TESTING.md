# API Testing Guide — Full Reference

Runnable examples for every endpoint. Use placeholders; replace with real values from responses.

**Auth:** JWT Bearer token (recommended) or DevAuth headers (local only).  
**Base URL:** `http://localhost:8080` (or `<BASE_URL>`)

**Postman:** Import [postman/AYRNOW.postman_collection.json](postman/AYRNOW.postman_collection.json). Set `BASE_URL` and `ACCESS_TOKEN` in collection variables.

---

## Placeholders

| Placeholder | Source |
|-------------|--------|
| `<BASE_URL>` | e.g. `http://localhost:8080` |
| `<ACCESS_TOKEN>` | From register or login |
| `<ACCOUNT_ID>` | From /me or auth response |
| `<USER_ID>` | From /me or auth response |
| `<PROPERTY_ID>` | From create property |
| `<UNIT_ID>` | From create unit |
| `<LEASE_ID>` | From create lease |
| `<TICKET_ID>` | From create ticket |
| `<CONTRACTOR_ID>` | From create contractor |
| `<POST_ID>` | From create post |
| `<INVITE_TOKEN>` | `inviteUrlToken` from create invite |
| `<SHARE_TOKEN>` | `shareToken` from tenant export |
| `<EXPORT_ID>` | From tenant export |
| `<REQUEST_ID>` | From request-review |
| `<ASSIGNMENT_ID>` | From create assignment |
| `<VISITOR_ID>` | From create visitor |

---

## 1. System / Health

### GET /api/v1/health

**Purpose:** Liveness probe. No auth.

```bash
curl -s <BASE_URL>/api/v1/health
```

**Response:** `{"status":"ok"}`

---

## 2. Auth

| Endpoint | Purpose | Auth |
|----------|---------|------|
| POST /auth/register | Create account + user + role | None |
| POST /auth/login | Get tokens | None |
| POST /auth/refresh | Rotate refresh token | None |
| POST /auth/logout | Revoke refresh token | None |

### POST /api/v1/auth/register

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"dev@test.com","password":"password123","displayName":"Dev User","role":"landlord","accountName":"Test Account"}' \
  <BASE_URL>/api/v1/auth/register
```

**Response:** `{"accessToken":"...","refreshToken":"...","userId":"...","accountId":"...","role":"landlord"}`  
**Errors:** 409 email exists; 400 accountName missing.

### POST /api/v1/auth/login

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"dev@test.com","password":"password123"}' \
  <BASE_URL>/api/v1/auth/login
```

### POST /api/v1/auth/refresh

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"refreshToken":"<REFRESH_TOKEN>"}' \
  <BASE_URL>/api/v1/auth/refresh
```

### POST /api/v1/auth/logout

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"refreshToken":"<REFRESH_TOKEN>"}' \
  <BASE_URL>/api/v1/auth/logout
```

**Response:** 204 No Content.

---

## 3. Me

### GET /api/v1/me

**Purpose:** Current user + account context. **Auth:** Required.

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/me
```

**Response:** `{"accountId":"...","userId":"...","role":"...","email":"...","displayName":"..."}`

---

## 4. Properties

| Endpoint | Purpose | Auth |
|----------|---------|------|
| GET /properties | List | Landlord/pm |
| GET /properties/{id} | Get one | Landlord/pm |
| POST /properties | Create | Landlord/pm |
| PATCH /properties/{id} | Update | Landlord/pm |
| DELETE /properties/{id} | Soft delete | Landlord/pm; 409 if unit has lease |
| GET /properties/{id}/units | List units | Landlord/pm |
| POST /properties/{id}/units | Create unit | Landlord/pm |
| GET /properties/{id}/security-settings | Get | Landlord/pm/security_guard |
| PATCH /properties/{id}/security-settings | Update | Landlord/pm |

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/properties
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/properties/<PROPERTY_ID>
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"name":"Elm Apartments","address1":"123 Elm","city":"Buffalo","state":"NY","postalCode":"14201"}' \
  <BASE_URL>/api/v1/properties
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"name":"Elm Residences","address1":"123 Elm","city":"Buffalo","state":"NY","postalCode":"14201"}' \
  <BASE_URL>/api/v1/properties/<PROPERTY_ID>
curl -s -X DELETE -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/properties/<PROPERTY_ID>
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/properties/<PROPERTY_ID>/units
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"unitLabel":"101","status":"vacant"}' \
  <BASE_URL>/api/v1/properties/<PROPERTY_ID>/units
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/properties/<PROPERTY_ID>/security-settings
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"approvalRequired":true}' <BASE_URL>/api/v1/properties/<PROPERTY_ID>/security-settings
```

---

## 5. Units (+ Members, Invites)

| Endpoint | Purpose | Auth |
|----------|---------|------|
| GET /units/{id} | Get unit | Landlord/pm or tenant in unit |
| PATCH /units/{id} | Update | Landlord/pm |
| DELETE /units/{id} | Soft delete | Landlord/pm; 409 if active lease |
| GET /units/{id}/members | List members | Landlord/pm or tenant in unit |
| POST /units/{id}/invites | Create invite | Landlord/pm; 409 if unit has lease |
| GET /units/{id}/invites | List invites | Landlord/pm |

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/units/<UNIT_ID>
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"unitLabel":"102","status":"occupied"}' <BASE_URL>/api/v1/units/<UNIT_ID>
curl -s -X DELETE -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/units/<UNIT_ID>
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/units/<UNIT_ID>/members
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"contactType":"email","contactValue":"tenant@example.com","role":"tenant"}' \
  <BASE_URL>/api/v1/units/<UNIT_ID>/invites
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" "<BASE_URL>/api/v1/units/<UNIT_ID>/invites?page=0&size=20"
```

---

## 6. Invites (Resend, Cancel, Accept)

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/invites/<INVITE_ID>/resend
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/invites/<INVITE_ID>/cancel
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/invites/accept/<INVITE_TOKEN>
```

**Accept:** Adds caller's userId to unit_members. 409 if accepted/expired.

---

## 7. Leases (+ Tenants)

| Endpoint | Purpose | Auth |
|----------|---------|------|
| GET /leases | List | Landlord/pm |
| GET /leases/{id} | Get one | Landlord/pm or tenant |
| GET /leases/me/active | My active lease | Tenant |
| POST /leases | Create | Landlord/pm; 409 if unit has lease |
| PATCH /leases/{id} | Update dates | Landlord/pm |
| POST /leases/{id}/end | End lease | Landlord/pm; 409 if ended |
| GET /leases/{id}/tenants | List tenants | Landlord/pm or tenant |

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" "<BASE_URL>/api/v1/leases?page=0&size=20"
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/leases/<LEASE_ID>
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/leases/me/active
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"unitId":"<UNIT_ID>","tenantUserId":"<USER_ID>","startDate":"2025-01-01","endDate":"2025-12-31"}' \
  <BASE_URL>/api/v1/leases
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"startDate":"2025-01-01","endDate":"2026-01-31"}' <BASE_URL>/api/v1/leases/<LEASE_ID>
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"endDate":"2025-06-30"}' <BASE_URL>/api/v1/leases/<LEASE_ID>/end
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/leases/<LEASE_ID>/tenants
```

---

## 8. Maintenance Tickets (+ Comments, Assign, Close, Reopen)

| Endpoint | Purpose | Auth |
|----------|---------|------|
| GET /tickets | List | Landlord/pm or tenant (own units) |
| GET /tickets/{id} | Get one | Same |
| POST /tickets | Create | Tenant (in unit) or Landlord; 403 tenant on unrelated unit |
| PATCH /tickets/{id} | Update | Same |
| POST /tickets/{id}/comments | Add comment | Same |
| GET /tickets/{id}/comments | List comments | Same |
| POST /tickets/{id}/assign | Assign contractor | Landlord/pm; 409 if assigned |
| POST /tickets/{id}/close | Close | Landlord/pm |
| POST /tickets/{id}/reopen | Reopen | Landlord/pm; 409 if not closed |

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" "<BASE_URL>/api/v1/tickets?page=0&size=20"
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tickets/<TICKET_ID>
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"propertyId":"<PROPERTY_ID>","unitId":"<UNIT_ID>","title":"Leak","description":"Sink drips","priority":"medium"}' \
  <BASE_URL>/api/v1/tickets
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"priority":"high"}' <BASE_URL>/api/v1/tickets/<TICKET_ID>
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"body":"Got worse"}' <BASE_URL>/api/v1/tickets/<TICKET_ID>/comments
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tickets/<TICKET_ID>/comments
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"contractorId":"<CONTRACTOR_ID>"}' <BASE_URL>/api/v1/tickets/<TICKET_ID>/assign
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tickets/<TICKET_ID>/close
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tickets/<TICKET_ID>/reopen
```

---

## 9. Contractors (+ Assignments)

| Endpoint | Purpose | Auth |
|----------|---------|------|
| GET /contractors | List | Landlord/pm |
| GET /contractors/{id} | Get one | Same |
| POST /contractors | Create | Same |
| PATCH /contractors/{id} | Update | Same |
| DELETE /contractors/{id} | Delete | Same |
| GET /contractors/{id}/assignments | List | Same |

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" "<BASE_URL>/api/v1/contractors?page=0&size=20"
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/contractors/<CONTRACTOR_ID>
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"name":"ABC Plumbing","email":"c@abc.com","phone":"+15551234567","specialty":"plumbing"}' \
  <BASE_URL>/api/v1/contractors
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"status":"inactive"}' <BASE_URL>/api/v1/contractors/<CONTRACTOR_ID>
curl -s -X DELETE -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/contractors/<CONTRACTOR_ID>
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/contractors/<CONTRACTOR_ID>/assignments
```

### Assignments

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"ticketId":"<TICKET_ID>","contractorId":"<CONTRACTOR_ID>","notes":"48h"}' <BASE_URL>/api/v1/assignments
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"status":"accepted"}' <BASE_URL>/api/v1/assignments/<ASSIGNMENT_ID>
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/assignments/<ASSIGNMENT_ID>/complete
```

---

## 10. Community (+ Comments, Reactions)

| Endpoint | Purpose | Auth |
|----------|---------|------|
| GET /posts | List | Landlord/pm/tenant |
| GET /posts/{id} | Get one | Same |
| POST /posts | Create | Landlord/pm |
| POST /posts/{id}/comments | Add comment | Same |
| GET /posts/{id}/comments | List | Same |
| POST /posts/{id}/reactions | React | Same; kind: like/love/laugh/sad/angry |

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" "<BASE_URL>/api/v1/posts?page=0&size=20"
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/posts/<POST_ID>
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"title":"Maintenance","body":"Water off 9am.","kind":"announcement"}' <BASE_URL>/api/v1/posts
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"body":"Thanks"}' <BASE_URL>/api/v1/posts/<POST_ID>/comments
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/posts/<POST_ID>/comments
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"reaction":"like"}' <BASE_URL>/api/v1/posts/<POST_ID>/reactions
```

---

## 11. Notifications

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" "<BASE_URL>/api/v1/notifications?page=0&size=20"
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"all":true}' <BASE_URL>/api/v1/notifications/read
```

---

## 12. Security Settings + Visitors

| Endpoint | Purpose | Auth |
|----------|---------|------|
| GET /visitors | List | Landlord/pm/security_guard |
| POST /visitors | Create entry | security_guard/landlord; status=pending if approvalRequired |
| POST /visitors/{id}/approve | Approve | Landlord; 409 if not pending |
| POST /visitors/{id}/deny | Deny | Landlord |

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/visitors?propertyId=<PROPERTY_ID>&status=pending&page=0&size=20"
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"propertyId":"<PROPERTY_ID>","visitorName":"John","visitorPhone":"+15551234567","purpose":"Delivery"}' \
  <BASE_URL>/api/v1/visitors
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/visitors/<VISITOR_ID>/approve
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/visitors/<VISITOR_ID>/deny
```

---

## 13. Ledger + Balances

All ledger writes require `Idempotency-Key` header (UUID).

| Endpoint | Purpose | Auth |
|----------|---------|------|
| GET /ledger/units/{id} | List by unit | Landlord/pm/tenant |
| GET /ledger/leases/{id} | List by lease | Same |
| POST /ledger/charges | Create charge | Landlord |
| POST /ledger/payments | Create payment | Tenant |
| POST /ledger/refunds | Refund | Landlord |
| POST /ledger/adjustments | Adjust | Landlord |
| GET /balances/units/{id} | Unit balance | Same |
| GET /balances/leases/{id} | Lease balance | Same |

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/ledger/units/<UNIT_ID>?page=0&size=20"
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/ledger/leases/<LEASE_ID>?page=0&size=20"
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{"unitId":"<UNIT_ID>","subtype":"rent","amountCents":150000,"occurredOn":"2025-01-01","memo":"Rent"}' \
  <BASE_URL>/api/v1/ledger/charges
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{"unitId":"<UNIT_ID>","leaseId":"<LEASE_ID>","amountCents":150000,"occurredOn":"2025-01-02","memo":"Rent"}' \
  <BASE_URL>/api/v1/ledger/payments
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/balances/units/<UNIT_ID>
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/balances/leases/<LEASE_ID>
```

---

## 14. Stripe (Checkout, Webhook, History)

| Endpoint | Purpose | Auth |
|----------|---------|------|
| POST /payments/stripe/checkout-session | Create session | Tenant |
| GET /payments/history | List payments | Landlord/pm |
| POST /payments/stripe/webhook | Stripe webhook | Stripe-Signature |

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"unitId":"<UNIT_ID>","leaseId":"<LEASE_ID>","amountCents":150000}' \
  <BASE_URL>/api/v1/payments/stripe/checkout-session
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/payments/history?unitId=<UNIT_ID>&page=0&size=20"
```

**Webhook:** Stripe sends POST; verified via `Stripe-Signature`. Local test: `stripe listen --forward-to localhost:8080/api/v1/payments/stripe/webhook`.

---

## 15. Tenant Transfer Profile

| Endpoint | Purpose | Auth |
|----------|---------|------|
| GET /tenant-profile/me | My profile | Tenant |
| POST /tenant-profile/me/export | Create share | Tenant |
| POST /tenant-profile/me/exports/{id}/revoke | Revoke | Tenant (owner) |
| GET /tenant-profile/share/{token} | View (redacted/full) | Any |
| POST /tenant-profile/share/{token}/request-review | Request | Landlord/pm |
| POST /tenant-profile/requests/{id}/approve | Approve | Tenant (owner) |
| POST /tenant-profile/requests/{id}/reject | Reject | Tenant (owner) |
| POST /tenant-profile/share/{token}/import | Import summary | Landlord/pm (approved only) |

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tenant-profile/me
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tenant-profile/me/export
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tenant-profile/me/exports/<EXPORT_ID>/revoke
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tenant-profile/share/<SHARE_TOKEN>
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tenant-profile/share/<SHARE_TOKEN>/request-review
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tenant-profile/requests/<REQUEST_ID>/approve
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tenant-profile/requests/<REQUEST_ID>/reject
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/tenant-profile/share/<SHARE_TOKEN>/import
```

---

## Happy Path Walkthrough

End-to-end: **register → property → unit → invite → accept → lease → charge → checkout → webhook → balance**

```bash
BASE=http://localhost:8080

# 1. Register (landlord)
R=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"walk@test.com","password":"pass123","displayName":"Landlord","role":"landlord","accountName":"Walk Co"}' \
  $BASE/api/v1/auth/register)
L_TOKEN=$(echo $R | jq -r '.accessToken')
L_USER=$(echo $R | jq -r '.userId')

# 2. Create property
P=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $L_TOKEN" \
  -d '{"name":"Walk Apt","address1":"1 Main","city":"Buffalo","state":"NY","postalCode":"14201"}' \
  $BASE/api/v1/properties)
PROP=$(echo $P | jq -r '.id')

# 3. Create unit
U=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $L_TOKEN" \
  -d '{"unitLabel":"1","status":"vacant"}' $BASE/api/v1/properties/$PROP/units)
UNIT=$(echo $U | jq -r '.id')

# 4. Create invite
INV=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $L_TOKEN" \
  -d '{"contactType":"email","contactValue":"tenant@walk.test","role":"tenant"}' \
  $BASE/api/v1/units/$UNIT/invites)
INV_TOKEN=$(echo $INV | jq -r '.inviteUrlToken')

# 5. Register tenant, accept invite
R2=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"tenant@walk.test","password":"pass123","displayName":"Tenant","role":"tenant","accountName":"Walk Co"}' \
  $BASE/api/v1/auth/register)
T_TOKEN=$(echo $R2 | jq -r '.accessToken')
T_USER=$(echo $R2 | jq -r '.userId')
curl -s -X POST -H "Authorization: Bearer $T_TOKEN" $BASE/api/v1/invites/accept/$INV_TOKEN

# 6. Create lease (landlord)
L=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $L_TOKEN" \
  -d "{\"unitId\":\"$UNIT\",\"tenantUserId\":\"$T_USER\",\"startDate\":\"2025-01-01\",\"endDate\":\"2025-12-31\"}" \
  $BASE/api/v1/leases)
LEASE=$(echo $L | jq -r '.id')

# 7. Charge rent (landlord)
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $L_TOKEN" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d "{\"unitId\":\"$UNIT\",\"subtype\":\"rent\",\"amountCents\":150000,\"occurredOn\":\"2025-01-01\",\"memo\":\"Rent\"}" \
  $BASE/api/v1/ledger/charges

# 8. Create checkout session (tenant) — open checkoutUrl in browser or simulate
CHK=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $T_TOKEN" \
  -d "{\"unitId\":\"$UNIT\",\"leaseId\":\"$LEASE\",\"amountCents\":150000}" \
  $BASE/api/v1/payments/stripe/checkout-session)
echo $CHK | jq .
# checkoutUrl: complete payment in Stripe (test card 4242...)
# Or: stripe trigger checkout.session.completed (for webhook test)

# 9. Webhook: run in another terminal: stripe listen --forward-to localhost:8080/api/v1/payments/stripe/webhook
# Use printed whsec_... as STRIPE_WEBHOOK_SECRET. Complete checkout or: stripe trigger checkout.session.completed

# 10. Verify ledger and balance after webhook processes payment
curl -s -H "Authorization: Bearer $L_TOKEN" "$BASE/api/v1/ledger/units/$UNIT?page=0&size=20"
curl -s -H "Authorization: Bearer $L_TOKEN" "$BASE/api/v1/balances/units/$UNIT"
curl -s -H "Authorization: Bearer $L_TOKEN" "$BASE/api/v1/balances/leases/$LEASE"
```

---

## Common Errors

| HTTP | error | When |
|------|-------|------|
| 400 | validation_error | Invalid body; check `fields` |
| 400 | bad_request | Business rule |
| 401 | unauthorized | Missing/invalid auth |
| 403 | forbidden | Wrong role/scope |
| 404 | not_found | Resource missing |
| 409 | conflict | Duplicate, already ended, etc. |
