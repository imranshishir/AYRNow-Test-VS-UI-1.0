# API Testing Guide — Full Reference

Runnable examples for every endpoint. Use placeholders; replace with real values from responses.

**Auth:** JWT Bearer token (recommended) or DevAuth headers (local only).  
**Base URL:** `http://localhost:8080` (or `<BASE_URL>`)

**Postman:** Import `docs/postman/AYRNOW.postman_collection.json`. Set `BASE_URL` and `ACCESS_TOKEN` in collection variables.

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

No auth.

```bash
curl -s <BASE_URL>/api/v1/health
```

**Response:** `{"status":"ok"}`

---

## 2. Auth

### POST /api/v1/auth/register

No auth. Creates account + user + role.

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"dev@test.com","password":"password123","displayName":"Dev User","role":"landlord","accountName":"Test Account"}' \
  <BASE_URL>/api/v1/auth/register
```

**Response:** `{"accessToken":"...","refreshToken":"...","userId":"...","accountId":"...","role":"landlord"}`  
**Errors:** 409 if email exists; 400 if accountName missing (required for now).

### POST /api/v1/auth/login

No auth.

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"dev@test.com","password":"password123"}' \
  <BASE_URL>/api/v1/auth/login
```

**Response:** Same as register.

### POST /api/v1/auth/refresh

No auth. Rotates refresh token.

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"refreshToken":"<REFRESH_TOKEN>"}' \
  <BASE_URL>/api/v1/auth/refresh
```

**Response:** New `accessToken` + `refreshToken`.

### POST /api/v1/auth/logout

No auth.

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"refreshToken":"<REFRESH_TOKEN>"}' \
  <BASE_URL>/api/v1/auth/logout
```

**Response:** 204 No Content.

---

## 3. Me

### GET /api/v1/me

Auth required.

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/me
```

**Response:** `{"accountId":"...","userId":"...","role":"...","email":"...","displayName":"..."}`  
**Prereq:** Logged-in user.

---

## 4. Properties

### List properties

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/properties
```

**Response:** Array of properties.

### Get property

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/properties/<PROPERTY_ID>
```

### Create property

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"name":"Elm Apartments","address1":"123 Elm","city":"Buffalo","state":"NY","postalCode":"14201"}' \
  <BASE_URL>/api/v1/properties
```

**Response:** Property with `id`. Save as `<PROPERTY_ID>`.

### Patch property

```bash
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"name":"Elm Residences","address1":"123 Elm","city":"Buffalo","state":"NY","postalCode":"14201"}' \
  <BASE_URL>/api/v1/properties/<PROPERTY_ID>
```

### Delete property

```bash
curl -s -X DELETE -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/properties/<PROPERTY_ID>
```

**Errors:** 409 if any unit has active lease.

### List units for property

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/properties/<PROPERTY_ID>/units
```

### Create unit

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"unitLabel":"101","status":"vacant"}' \
  <BASE_URL>/api/v1/properties/<PROPERTY_ID>/units
```

**Response:** Unit with `id`. Save as `<UNIT_ID>`.

### Get security settings

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/properties/<PROPERTY_ID>/security-settings
```

### Patch security settings

```bash
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"approvalRequired":true}' \
  <BASE_URL>/api/v1/properties/<PROPERTY_ID>/security-settings
```

---

## 5. Units

### Get unit

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" <BASE_URL>/api/v1/units/<UNIT_ID>
```

### Patch unit

```bash
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"unitLabel":"102","status":"occupied"}' \
  <BASE_URL>/api/v1/units/<UNIT_ID>
```

### Delete unit

```bash
curl -s -X DELETE -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/units/<UNIT_ID>
```

**Errors:** 409 if unit has active lease.

### List unit members

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/units/<UNIT_ID>/members
```

**Prereq:** Landlord/pm or tenant in unit.

### Create invite

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"contactType":"email","contactValue":"tenant@example.com","role":"tenant"}' \
  <BASE_URL>/api/v1/units/<UNIT_ID>/invites
```

**Response:** Invite with `inviteUrlToken`. Save as `<INVITE_TOKEN>`.  
**Errors:** 409 if unit has active lease.

### List invites for unit

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/units/<UNIT_ID>/invites?page=0&size=20"
```

---

## 6. Invites

### Resend invite

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/invites/<INVITE_ID>/resend
```

### Cancel invite

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/invites/<INVITE_ID>/cancel
```

### Accept invite

Use `inviteUrlToken` from create response (not invite ID).

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/invites/accept/<INVITE_TOKEN>
```

**Prereq:** Acceptor must be authenticated. Adds userId to unit_members.  
**Errors:** 409 if already accepted or expired.

---

## 7. Leases

### List leases

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/leases?page=0&size=20"

# With filters
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/leases?status=active&unitId=<UNIT_ID>"
```

### Get lease

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/leases/<LEASE_ID>
```

### Get my active lease (tenant)

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/leases/me/active
```

**Response:** 404 if no active lease.

### Create lease

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"unitId":"<UNIT_ID>","tenantUserId":"<USER_ID>","startDate":"2025-01-01","endDate":"2025-12-31"}' \
  <BASE_URL>/api/v1/leases
```

**Response:** Lease with `id`. Save as `<LEASE_ID>`.  
**Errors:** 409 if unit already has active lease.

### Patch lease

```bash
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"startDate":"2025-01-01","endDate":"2026-01-31"}' \
  <BASE_URL>/api/v1/leases/<LEASE_ID>
```

### End lease

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"endDate":"2025-06-30"}' \
  <BASE_URL>/api/v1/leases/<LEASE_ID>/end
```

**Errors:** 409 if already ended.

### List lease tenants

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/leases/<LEASE_ID>/tenants
```

---

## 8. Maintenance Tickets

### List tickets

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/tickets?page=0&size=20"

# Filters: unitId, status
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/tickets?unitId=<UNIT_ID>&status=open"
```

### Create ticket

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"propertyId":"<PROPERTY_ID>","unitId":"<UNIT_ID>","title":"Leaking faucet","description":"Kitchen sink","priority":"medium"}' \
  <BASE_URL>/api/v1/tickets
```

**Response:** Ticket with `id`. Save as `<TICKET_ID>`.  
**Prereq:** Tenant: must be in unit; Landlord: any unit.  
**Errors:** 403 if tenant on unrelated unit.

### Get ticket

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tickets/<TICKET_ID>
```

### Patch ticket

```bash
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"title":"Urgent","priority":"high"}' \
  <BASE_URL>/api/v1/tickets/<TICKET_ID>
```

### Add comment

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"body":"The leak got worse."}' \
  <BASE_URL>/api/v1/tickets/<TICKET_ID>/comments
```

### List comments

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tickets/<TICKET_ID>/comments
```

### Assign contractor

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"contractorId":"<CONTRACTOR_ID>"}' \
  <BASE_URL>/api/v1/tickets/<TICKET_ID>/assign
```

**Errors:** 409 if already assigned.

### Close ticket

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tickets/<TICKET_ID>/close
```

### Reopen ticket

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tickets/<TICKET_ID>/reopen
```

**Errors:** 409 if not closed.

---

## 9. Contractors

### List contractors

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/contractors?page=0&size=20"
```

### Create contractor

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"name":"ABC Plumbing","email":"contact@abc.com","phone":"+15551234567","specialty":"plumbing"}' \
  <BASE_URL>/api/v1/contractors
```

**Response:** Contractor with `id`. Save as `<CONTRACTOR_ID>`.

### Get contractor

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/contractors/<CONTRACTOR_ID>
```

### Patch contractor

```bash
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"status":"inactive"}' \
  <BASE_URL>/api/v1/contractors/<CONTRACTOR_ID>
```

### Delete contractor

```bash
curl -s -X DELETE -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/contractors/<CONTRACTOR_ID>
```

### List contractor assignments

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/contractors/<CONTRACTOR_ID>/assignments
```

---

## 10. Assignments

### Create assignment

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"ticketId":"<TICKET_ID>","contractorId":"<CONTRACTOR_ID>","notes":"Schedule within 48h"}' \
  <BASE_URL>/api/v1/assignments
```

**Response:** Assignment with `id`.  
**Errors:** 409 if ticket already has assignment.

### Patch assignment

```bash
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"status":"accepted"}' \
  <BASE_URL>/api/v1/assignments/<ASSIGNMENT_ID>
```

### Complete assignment

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/assignments/<ASSIGNMENT_ID>/complete
```

---

## 11. Community Posts

### List posts

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/posts?page=0&size=20"

# Filters: propertyId, unitId, kind
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/posts?kind=announcement"
```

### Create post

```bash
# Account-wide
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"title":"Maintenance Monday","body":"Water shutoff 9am-12pm.","kind":"announcement"}' \
  <BASE_URL>/api/v1/posts

# Property-specific
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"propertyId":"<PROPERTY_ID>","title":"Parking lot work","body":"Lot closed next week.","kind":"alert"}' \
  <BASE_URL>/api/v1/posts
```

**Response:** Post with `id`. Save as `<POST_ID>`.  
**kind:** `announcement`, `event`, `alert`.

### Get post

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/posts/<POST_ID>
```

### Add comment

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"body":"Thanks for the heads up!"}' \
  <BASE_URL>/api/v1/posts/<POST_ID>/comments
```

### List comments

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/posts/<POST_ID>/comments
```

### React to post

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"reaction":"like"}' \
  <BASE_URL>/api/v1/posts/<POST_ID>/reactions
```

**reaction:** `like`, `love`, `laugh`, `sad`, `angry`.

---

## 12. Notifications

### List notifications

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/notifications?page=0&size=20"
```

### Mark read

```bash
# By IDs
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"notificationIds":["<ID1>","<ID2>"]}' \
  <BASE_URL>/api/v1/notifications/read

# All
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"all":true}' \
  <BASE_URL>/api/v1/notifications/read
```

---

## 13. Security Guard: Security Settings + Visitors

### Get security settings

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/properties/<PROPERTY_ID>/security-settings
```

### Patch security settings

```bash
curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"approvalRequired":true}' \
  <BASE_URL>/api/v1/properties/<PROPERTY_ID>/security-settings
```

### List visitors

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/visitors?propertyId=<PROPERTY_ID>&status=pending&page=0&size=20"
```

### Create visitor entry

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"propertyId":"<PROPERTY_ID>","visitorName":"John Doe","visitorPhone":"+15551234567","purpose":"Delivery"}' \
  <BASE_URL>/api/v1/visitors
```

**Response:** Visitor with `id`. Save as `<VISITOR_ID>`.  
**Prereq:** security_guard or landlord. Status: `pending` if approvalRequired, else `logged`.

### Approve visitor

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/visitors/<VISITOR_ID>/approve
```

**Errors:** 409 if not pending.

### Deny visitor

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/visitors/<VISITOR_ID>/deny
```

---

## 14. Ledger

All write endpoints require `Idempotency-Key` header (UUID). Use same key for retries.

### List ledger by unit

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/ledger/units/<UNIT_ID>?from=2025-01-01&to=2025-01-31&page=0&size=20"
```

### List ledger by lease

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/ledger/leases/<LEASE_ID>?page=0&size=20"
```

### Create charge

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{"unitId":"<UNIT_ID>","subtype":"rent","amountCents":150000,"occurredOn":"2025-01-01","memo":"January rent"}' \
  <BASE_URL>/api/v1/ledger/charges
```

**subtype:** `rent`, `utility`, `fee`, `other`.

### Create payment

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{"unitId":"<UNIT_ID>","leaseId":"<LEASE_ID>","amountCents":150000,"occurredOn":"2025-01-02","memo":"Rent payment"}' \
  <BASE_URL>/api/v1/ledger/payments
```

### Create refund

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{"unitId":"<UNIT_ID>","amountCents":10000,"occurredOn":"2025-01-15","memo":"Overpayment refund"}' \
  <BASE_URL>/api/v1/ledger/refunds
```

### Create adjustment

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{"unitId":"<UNIT_ID>","direction":"credit","amountCents":5000,"occurredOn":"2025-01-15","memo":"Courtesy credit"}' \
  <BASE_URL>/api/v1/ledger/adjustments
```

**direction:** `debit`, `credit`.

### Get balance (unit)

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/balances/units/<UNIT_ID>?asOf=2025-01-15"
```

### Get balance (lease)

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/balances/leases/<LEASE_ID>
```

---

## 15. Stripe

### Create checkout session

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"unitId":"<UNIT_ID>","leaseId":"<LEASE_ID>","amountCents":150000}' \
  <BASE_URL>/api/v1/payments/stripe/checkout-session
```

**Response:** `{"checkoutSessionId":"...","checkoutUrl":"https://checkout.stripe.com/..."}`  
**Prereq:** STRIPE_SECRET_KEY set. Tenant role for paying.

### List payment history

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "<BASE_URL>/api/v1/payments/history?unitId=<UNIT_ID>&page=0&size=20"
```

### Webhook

Stripe sends POST to `/api/v1/payments/stripe/webhook`. No auth; verified via `Stripe-Signature`. Configure in Stripe Dashboard; use Stripe CLI for local: `stripe listen --forward-to localhost:8080/api/v1/payments/stripe/webhook`.

---

## 16. Tenant Transfer

### Get my profile

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tenant-profile/me
```

### Create export

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tenant-profile/me/export
```

**Response:** `{"exportId":"...","shareToken":"...","expiresAt":"...","shareUrl":"..."}`  
**Prereq:** Tenant-like role.

### Revoke export

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tenant-profile/me/exports/<EXPORT_ID>/revoke
```

### View by share token

```bash
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tenant-profile/share/<SHARE_TOKEN>
```

Redacted or full based on caller (tenant vs landlord with approval).

### Request review (landlord)

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tenant-profile/share/<SHARE_TOKEN>/request-review
```

**Errors:** 409 if already pending for same account.

### Approve request (tenant)

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tenant-profile/requests/<REQUEST_ID>/approve
```

### Reject request (tenant)

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tenant-profile/requests/<REQUEST_ID>/reject
```

### Import (landlord)

```bash
curl -s -X POST -H "Authorization: Bearer <ACCESS_TOKEN>" \
  <BASE_URL>/api/v1/tenant-profile/share/<SHARE_TOKEN>/import
```

**Prereq:** Approved request for caller's account.  
**Errors:** 409 if no approved request.

---

## Happy Path Walkthrough

```bash
BASE=<BASE_URL>

# 1. Register
R=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"walk@test.com","password":"pass123","displayName":"Walk User","role":"landlord","accountName":"Walk Co"}' \
  $BASE/api/v1/auth/register)
TOKEN=$(echo $R | jq -r '.accessToken')
USER=$(echo $R | jq -r '.userId')

# 2. Create property
P=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Walk Apt","address1":"1 Main","city":"Buffalo","state":"NY","postalCode":"14201"}' \
  $BASE/api/v1/properties)
PROP=$(echo $P | jq -r '.id')

# 3. Create unit
U=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d '{"unitLabel":"1","status":"vacant"}' \
  $BASE/api/v1/properties/$PROP/units)
UNIT=$(echo $U | jq -r '.id')

# 4. Create invite
INV=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d '{"contactType":"email","contactValue":"t@test.com","role":"tenant"}' \
  $BASE/api/v1/units/$UNIT/invites)
# (Accept invite as tenant user - use different token)

# 5. Create lease (use same user as tenant for simplicity)
L=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d "{\"unitId\":\"$UNIT\",\"tenantUserId\":\"$USER\",\"startDate\":\"2025-01-01\",\"endDate\":\"2025-12-31\"}" \
  $BASE/api/v1/leases)
LEASE=$(echo $L | jq -r '.id')

# 6. Charge rent
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d "{\"unitId\":\"$UNIT\",\"subtype\":\"rent\",\"amountCents\":150000,\"occurredOn\":\"2025-01-01\",\"memo\":\"Rent\"}" \
  $BASE/api/v1/ledger/charges

# 7. Pay (as tenant - use tenant token)
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d "{\"unitId\":\"$UNIT\",\"leaseId\":\"$LEASE\",\"amountCents\":150000,\"occurredOn\":\"2025-01-02\",\"memo\":\"Rent\"}" \
  $BASE/api/v1/ledger/payments

# 8. Check balance
curl -s -H "Authorization: Bearer $TOKEN" \
  $BASE/api/v1/balances/units/$UNIT
curl -s -H "Authorization: Bearer $TOKEN" \
  $BASE/api/v1/balances/leases/$LEASE
```

---

## Common Errors

| HTTP | error | When |
|------|-------|------|
| 400 | validation_error | Invalid request body; check `fields` |
| 400 | bad_request | Business rule (e.g. unit has lease) |
| 401 | unauthorized | Missing/invalid auth |
| 403 | forbidden | Valid auth, wrong role/scope |
| 404 | not_found | Resource missing or not in account |
| 409 | conflict | State conflict (duplicate, already ended, etc.) |
