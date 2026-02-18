# Frontend ↔ Backend Integration Plan

Incremental integration of the Flutter app with the AYRNOW Spring Boot backend (B0–B13). Replace mock data screen-by-screen with real API calls.

---

## 1. Base URL Strategy

| Environment | Base URL | How to Configure |
|-------------|----------|------------------|
| **Local** | `http://localhost:8080` (Android emulator) | `lib/core/api/api_config.dart` |
| **Local iOS** | `http://127.0.0.1:8080` or `http://localhost:8080` | iOS simulator can use localhost; physical device needs LAN IP |
| **Staging** | `https://api-staging.ayrnow.com` | Env / flavor |
| **Production** | `https://api.ayrnow.com` | Env / flavor |

**Configuration:** Use `ApiConfig` singleton (or Riverpod provider). For flavors: `--dart-define=API_BASE_URL=...` or `.env` via `flutter_dotenv`. Default: `http://localhost:8080`.

---

## 2. Auth Strategy

- **Access token:** JWT, 15 min expiry; store in `flutter_secure_storage`
- **Refresh token:** 30-day expiry; store alongside access token
- **Flow:** On 401 → call `POST /auth/refresh` with refresh token → retry original request once → if refresh fails, clear tokens and redirect to login
- **Secure storage:** `flutter_secure_storage` for `access_token`, `refresh_token`, `user_id`, `account_id`, `role`
- **Logout:** Call `POST /auth/logout` with refresh token, then clear storage
- **Register:** `POST /auth/register` with `email`, `password`, `displayName`, `role`, `accountName` → store tokens and user context

---

## 3. Error Handling Standard

Backend error envelope:

```json
{
  "error": "validation_error|bad_request|unauthorized|forbidden|not_found|conflict|internal_error",
  "message": "Human-readable message",
  "fields": { "fieldName": "validation message" }  // only for validation_error
}
```

**Mapping to UI:**
- `validation_error` → show `fields` map or `message` under form fields
- `unauthorized` → trigger refresh or redirect to login
- `forbidden` → "You don't have permission to do this"
- `not_found` → "Resource not found"
- `conflict` → show `message` (e.g. "Unit already has active lease")
- `bad_request` / `internal_error` → show `message` or generic "Something went wrong"

Use typed exceptions: `ApiException` with `errorCode`, `message`, `fields`.

---

## 4. Pagination Handling Pattern

Backend returns `PageResponse<T>`:

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

**Pattern:** Fetch page 0 on load; support "load more" (page+1) for infinite scroll. Store `content`, `totalElements`, `last` in state. Params: `page` (default 0), `size` (default 20).

---

## 5. Idempotency-Key Handling for Ledger

Ledger write endpoints (`charges`, `payments`, `refunds`, `adjustments`) require `Idempotency-Key` header (UUID).

**Strategy:**
- Generate UUID per write attempt (e.g. `uuid.v4()`)
- Store in memory for retry: same key + same payload → 201 (cached); same key + different payload → 409
- Use `IdempotencyInterceptor`: add header only for `POST /api/v1/ledger/*` paths
- On 409 Idempotency conflict: show "Duplicate request" or treat as success if cached response returned

---

## 6. Stripe Checkout Flow Plan

1. **Create session:** `POST /payments/stripe/checkout-session` with `unitId`, `leaseId`, `amountCents`
2. **Response:** `checkoutSessionId`, `checkoutUrl`
3. **Open:** `url_launcher` or `webview_flutter` to open `checkoutUrl`
4. **Success:** Backend redirects to `STRIPE_SUCCESS_URL`; app can use deep link or custom scheme to return to app
5. **Cancel:** Redirect to `STRIPE_CANCEL_URL`
6. **Poll (optional):** If no deep link, poll `GET /payments/history?unitId=...` or `GET /ledger/units/{unitId}` until payment appears
7. **Webhook:** Backend processes Stripe webhook; ledger updated automatically

---

## 7. Safe Rollout Plan

- **Feature flags:** Per-module toggle (mock vs real API) via `FeatureFlagsProvider`
- **Order:** 1) Auth + Me + Properties → 2) Units + Invites → 3) Leases → 4) Maintenance Tickets → 5) Contractors → 6) Community → 7) Security Guard → 8) Ledger + Payments → 9) Tenant Transfer
- **Fallback:** If real API fails (network/timeout), optionally fall back to mock for that request (configurable)
- **Logging:** Log which backend is used per request (for debugging)

---

## 8. Screen → API Mapping Table

### A) Auth (register / login / refresh / logout)

| Screen | Route/File | Backend Endpoints | DTOs | States | Edge Cases |
|--------|------------|-------------------|------|--------|------------|
| Login | `lib/features/auth/screens/login_screen.dart` | POST /auth/login | LoginRequest, AuthResponse | loading, error, success | 401 invalid creds; 400 validation |
| Register | `lib/features/auth/screens/register_screen.dart` | POST /auth/register | RegisterRequest, AuthResponse | loading, error, success | 409 email exists; 400 validation |
| (Token refresh) | Interceptor | POST /auth/refresh | RefreshRequest, AuthResponse | — | 401 refresh expired → logout |
| Logout | `lib/features/auth/screens/t_profile.dart` etc. | POST /auth/logout | LogoutRequest | — | 204 |

**Permissions:** None (public). Auth response: `accessToken`, `refreshToken`, `userId`, `accountId`, `role`.

---

### B) Landlord: Properties → Units → Unit tabs

| Screen | Route/File | Backend Endpoints | DTOs | States | Edge Cases |
|--------|------------|-------------------|------|--------|------------|
| Properties list | `lib/features/landlord/screens/ll_properties_list_screen.dart` | GET /properties | PropertyResponse | loading, empty, error, success | 403 non-landlord |
| Property detail | `lib/features/landlord/screens/ll_property_detail_screen.dart` | GET /properties/{id}, GET /properties/{id}/units | PropertyResponse, UnitResponse[] | same | 404 |
| Add property | `lib/features/landlord/screens/ll_add_property_screen.dart` | POST /properties | CreatePropertyRequest, PropertyResponse | loading, error, success | 400 validation |
| Unit tabs (overview, invites, leases) | `lib/features/landlord/unit/unit_tabs_screen.dart` | GET /units/{id}, GET /units/{id}/invites, GET /leases?unitId= | UnitResponse, TenantInviteResponse[], LeaseResponse[] | same | 403 tenant on other unit |
| Invite tenant | `lib/features/invite/screens/invite_tenant_screen.dart` | POST /units/{id}/invites | CreateInviteRequest, InviteResponse | same | 409 unit has lease |
| Pending invites | `lib/features/invite/screens/pending_invites_screen.dart` | GET /units/{id}/invites | InviteResponse[] | same | — |

**Permissions:** Landlord, manager, owner (staff). Tenant: read-only for own units.

---

### C) Tenant: Invite accept → tenant context → rent/payments

| Screen | Route/File | Backend Endpoints | DTOs | States | Edge Cases |
|--------|------------|-------------------|------|--------|------------|
| Invite accept | `lib/features/invite/screens/invite_accept_screen.dart` | POST /invites/accept/{token} | — | loading, error, success | 409 already accepted/expired |
| Tenant dashboard | `lib/features/tenant/screens/t_dashboard.dart` | GET /leases/me/active | LeaseResponse | same | 404 no lease |
| Rent / pay | `lib/features/tenant/screens/t_rent_flow.dart`, `t_pay.dart` | POST /payments/stripe/checkout-session, GET /balances/leases/{id} | CheckoutResponse, BalanceResponse | same | 403 tenant not on lease |
| Finance center | `lib/features/tenant/screens/t_finance_center.dart` | GET /ledger/leases/{id}, GET /balances/leases/{id} | LedgerEntryResponse[], BalanceResponse | same | — |

**Permissions:** Tenant, family, cotenant.

---

### D) Maintenance: tickets list / detail / comments / assign / close

| Screen | Route/File | Backend Endpoints | DTOs | States | Edge Cases |
|--------|------------|-------------------|------|--------|------------|
| Tickets list | `lib/features/landlord/unit/tabs/maintenance_inbox_tab.dart` | GET /tickets?page=&size= | TicketResponse[] (PageResponse) | same | 403 tenant on unrelated unit |
| Ticket detail | (inline / modal) | GET /tickets/{id}, GET /tickets/{id}/comments | TicketResponse, TicketCommentResponse[] | same | — |
| Create ticket | `lib/features/tenant/screens/t_tickets.dart` | POST /tickets | CreateTicketRequest, TicketResponse | same | 403 tenant not in unit |
| Add comment | — | POST /tickets/{id}/comments | CreateCommentRequest | same | — |
| Assign | — | POST /tickets/{id}/assign | AssignRequest | same | 409 already assigned |
| Close / Reopen | — | POST /tickets/{id}/close, POST /tickets/{id}/reopen | — | same | 409 not closed |

**Permissions:** Landlord/pm: full. Tenant: create for own units only; assign/close landlord only.

---

### E) Contractors: list / detail / assignments

| Screen | Route/File | Backend Endpoints | DTOs | States | Edge Cases |
|--------|------------|-------------------|------|--------|------------|
| Contractors list | `lib/features/landlord/screens/landlord_contractors_screen.dart` | GET /contractors?page=&size= | ContractorResponse[] | same | — |
| Contractor detail | — | GET /contractors/{id}, GET /contractors/{id}/assignments | ContractorResponse, AssignmentResponse[] | same | Contractor: own assignments only |
| Create contractor | — | POST /contractors | CreateContractorRequest | same | — |
| Create assignment | `lib/features/landlord/unit/tabs/contractors_tab.dart` | POST /assignments | CreateAssignmentRequest | same | 409 ticket already assigned |

**Permissions:** Landlord/pm: full. Contractor: view own assignments only.

---

### F) Community: posts / comments / reactions + notifications

| Screen | Route/File | Backend Endpoints | DTOs | States | Edge Cases |
|--------|------------|-------------------|------|--------|------------|
| Community feed | `lib/features/community/screens/community_feed_screen.dart` | GET /posts?page=&size= | PostResponse[] | same | — |
| Post detail | `lib/features/community/screens/community_post_detail_screen.dart` | GET /posts/{id}, GET /posts/{id}/comments | PostResponse, PostCommentResponse[] | same | — |
| Create post | `lib/features/community/widgets/community_create_post_sheet.dart` | POST /posts | CreatePostRequest | same | Landlord/pm only |
| React | — | POST /posts/{id}/reactions | CreateReactionRequest | same | — |
| Notifications | `lib/features/community/screens/community_inbox_screen.dart` | GET /notifications?page=&size=, POST /notifications/read | NotificationResponse[], MarkReadRequest | same | — |

**Permissions:** Landlord/pm: create posts. Tenant: view, comment, react.

---

### G) Security Guard: settings read, visitor log create / list / approve / deny

| Screen | Route/File | Backend Endpoints | DTOs | States | Edge Cases |
|--------|------------|-------------------|------|--------|------------|
| Settings | (property context) | GET /properties/{id}/security-settings | SecuritySettingsResponse | same | — |
| Visitor list | `lib/features/guard/screens/guard_active_visitors_screen.dart` | GET /visitors?propertyId=&status=&page= | VisitorResponse[] | same | — |
| Create visitor | `lib/features/guard/screens/guard_check_in_screen.dart` | POST /visitors | CreateVisitorRequest, VisitorResponse | same | status=pending if approvalRequired |
| Approve / Deny | `lib/features/guard/screens/guard_approvals_queue_screen.dart` | POST /visitors/{id}/approve, POST /visitors/{id}/deny | — | same | 409 not pending |

**Permissions:** Landlord/pm: approve, deny. Security_guard: create, list.

---

### H) Ledger: list entries, balances, create charge / payment / refund / adjustment

| Screen | Route/File | Backend Endpoints | DTOs | States | Edge Cases |
|--------|------------|-------------------|------|--------|------------|
| Ledger by unit | (landlord rent board) | GET /ledger/units/{id}?page=&size= | LedgerEntryResponse[] | same | Idempotency-Key for writes |
| Ledger by lease | (tenant finance) | GET /ledger/leases/{id} | same | same | — |
| Unit balance | — | GET /balances/units/{id}?asOf= | BalanceResponse | same | — |
| Lease balance | — | GET /balances/leases/{id} | same | same | — |
| Create charge | — | POST /ledger/charges | CreateChargeRequest | same | 400 missing Idempotency-Key |
| Create payment | — | POST /ledger/payments | CreatePaymentRequest | same | — |
| Refund / Adjustment | — | POST /ledger/refunds, POST /ledger/adjustments | CreateRefundRequest, CreateAdjustmentRequest | same | — |

**Permissions:** Landlord/pm: charges, refunds, adjustments. Tenant: payments (for own lease).

---

### I) Tenant Transfer Profile: export / share / request / approve / import / revoke

| Screen | Route/File | Backend Endpoints | DTOs | States | Edge Cases |
|--------|------------|-------------------|------|--------|------------|
| My profile | `lib/features/tenant/profile_portability/tenant_portable_profile_screen.dart` | GET /tenant-profile/me | TenantProfileResponse | same | — |
| Export | — | POST /tenant-profile/me/export | ExportResponse | same | Tenant only |
| Revoke | — | POST /tenant-profile/me/exports/{id}/revoke | — | same | — |
| View share | (landlord) | GET /tenant-profile/share/{token} | TenantProfileShareResponse (redacted/full) | same | — |
| Request review | — | POST /tenant-profile/share/{token}/request-review | TransferRequestResponse | same | 409 already pending |
| Approve / Reject | (tenant) | POST /tenant-profile/requests/{id}/approve, .../reject | same | same | — |
| Import | (landlord) | POST /tenant-profile/share/{token}/import | ImportSummaryResponse | same | 409 not approved |

**Permissions:** Tenant: export, approve, reject, revoke. Landlord: view, request, import.

---

## 9. Integration Order (Recommended)

1. **Auth + Me + Properties** ← First (implemented in scaffolding)
2. Units + Invites
3. Leases
4. Maintenance Tickets
5. Contractors
6. Community + Notifications
7. Security Guard
8. Ledger + Payments (Stripe)
9. Tenant Transfer Profile

---

## Related Docs

- [documentation/backend/API_TESTING.md](../backend/API_TESTING.md) — Full curl examples
- [documentation/backend/RUN_LOCAL.md](../backend/RUN_LOCAL.md) — Run backend locally
- [documentation/frontend/frontend_api_smoke_test.md](frontend_api_smoke_test.md) — Smoke test guide
