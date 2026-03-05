# AYRNOW Backend — Go Live ASAP Playbook

Deployment playbook for staging and production. No real secrets; use placeholders.

---

## 1) Chosen Stack: B) Railway (service) + Railway Postgres

**Why Railway:**
- **Speed:** One platform, one dashboard. Postgres + app in ~15 minutes.
- **Simplicity:** Connect GitHub → add Postgres → add service → set envs → deploy. No VPC, IAM, or reverse proxy.
- **Stability:** Managed Postgres, automatic restarts, health probes. HTTPS and custom domains built-in.
- **Cost:** $5 free credit/month; predictable pricing after. No surprise bills.

Alternatives: Render + Neon (similar simplicity). Fly.io (more config). DO/AWS (more ops).

---

## 2) Staging Steps

### 2.1 Create Railway Project

1. Sign up at [railway.app](https://railway.app).
2. **New Project** → **Deploy from GitHub repo**.
3. Select your repo (e.g. `AYRNow-Test-VS-UI-1.0`).
4. Railway creates an empty service.

### 2.2 Add PostgreSQL

1. In the project: **+ New** → **Database** → **PostgreSQL**.
2. Railway provisions Postgres and exposes `DATABASE_URL`.
3. Open the Postgres service → **Connect** → copy the connection details (or use `DATABASE_URL`).

### 2.3 Configure the Backend Service

1. Click the service that was created from your repo (the one that is NOT Postgres).
2. **Variables** tab → add:

| Variable | Value (placeholder) |
|----------|---------------------|
| `SPRING_PROFILES_ACTIVE` | `staging` |
| `SPRING_DATASOURCE_URL` | From Railway Postgres: `jdbc:postgresql://<host>:<port>/<db>?sslmode=require` (or derive from `DATABASE_URL` if Railway provides it) |
| `SPRING_DATASOURCE_USERNAME` | `<POSTGRES_USER>` (from Railway) |
| `SPRING_DATASOURCE_PASSWORD` | `<POSTGRES_PASSWORD>` (from Railway) |
| `JWT_SECRET` | `<JWT_SECRET>` (min 32 chars) |
| `STRIPE_SECRET_KEY` | `<STRIPE_SECRET_KEY_TEST>` (`sk_test_...`) |
| `STRIPE_WEBHOOK_SECRET` | `<STRIPE_WEBHOOK_SECRET_STAGING>` (`whsec_...`) |
| `STRIPE_SUCCESS_URL` | `https://<STAGING_DOMAIN>/payment/success` |
| `STRIPE_CANCEL_URL` | `https://<STAGING_DOMAIN>/payment/cancel` |

**Railway Postgres:** If your Postgres service exposes `DATABASE_URL` (e.g. `postgresql://user:pass@host:port/railway`), use:

- `SPRING_DATASOURCE_URL` = `jdbc:` + `postgresql://user:pass@host:port/railway?sslmode=require`
- `SPRING_DATASOURCE_USERNAME` = user from URL
- `SPRING_DATASOURCE_PASSWORD` = pass from URL

### 2.4 Build & Start Command

1. **Settings** → **Build**:
   - **Build Command:** `cd backend && mvn -B clean package -DskipTests`
   - **Root Directory:** `/` (or leave blank if repo root is project root)
2. **Settings** → **Deploy**:
   - **Start Command:** `cd backend && java -jar target/ayrnow-backend-0.1.0-SNAPSHOT.jar`
   - **Watch Paths:** `backend/**` (optional, for faster redeploys)

### 2.5 Port & Health Check

- Railway injects `PORT`. Spring Boot uses 8080 by default. Add to start command:
  **Start Command:** `cd backend && java -Dserver.port=${PORT:-8080} -jar target/ayrnow-backend-0.1.0-SNAPSHOT.jar`
- **Settings** → **Networking** → **Health Check:**
  - **Path:** `/api/v1/health`
  - **Timeout:** 30s (optional)

### 2.6 Generate Domain

1. **Settings** → **Networking** → **Generate Domain**.
2. Note the URL (e.g. `ayrnow-backend-staging.up.railway.app`). Use this as `<STAGING_BASE_URL>`.

---

## 3) Production Steps

### 3.1 Separate Project (Recommended)

1. Create a **new Railway project** for production.
2. **+ New** → **Database** → **PostgreSQL** (prod Postgres).
3. **+ New** → **GitHub Repo** → same repo, production branch (e.g. `main`).

### 3.2 Configure Prod Service

1. **Variables** → add (use prod placeholders):

| Variable | Value (placeholder) |
|----------|---------------------|
| `SPRING_PROFILES_ACTIVE` | `prod` |
| `SPRING_DATASOURCE_URL` | Prod Postgres JDBC URL |
| `SPRING_DATASOURCE_USERNAME` | `<POSTGRES_USER_PROD>` |
| `SPRING_DATASOURCE_PASSWORD` | `<POSTGRES_PASSWORD_PROD>` |
| `JWT_SECRET` | `<JWT_SECRET_PROD>` (min 32 chars, different from staging) |
| `STRIPE_SECRET_KEY` | `<STRIPE_SECRET_KEY_LIVE>` (`sk_live_...`) |
| `STRIPE_WEBHOOK_SECRET` | `<STRIPE_WEBHOOK_SECRET_PROD>` (`whsec_...` for live) |
| `STRIPE_SUCCESS_URL` | `https://<PROD_DOMAIN>/payment/success` |
| `STRIPE_CANCEL_URL` | `https://<PROD_DOMAIN>/payment/cancel` |

### 3.3 Build & Start (Same as Staging)

- **Build Command:** `cd backend && mvn -B clean package -DskipTests`
- **Start Command:** `cd backend && java -Dserver.port=${PORT:-8080} -jar target/ayrnow-backend-0.1.0-SNAPSHOT.jar`

### 3.4 Health Check

- **Health Check Path:** `/api/v1/health`

### 3.5 Generate Domain

- **Generate Domain** for prod (e.g. `ayrnow-backend-prod.up.railway.app`).

---

## 4) Env Var Mapping Table (Placeholders Only)

| Variable | Staging | Production |
|----------|---------|------------|
| `SPRING_PROFILES_ACTIVE` | `staging` | `prod` |
| `SPRING_DATASOURCE_URL` | `<STAGING_DATASOURCE_URL>` | `<PROD_DATASOURCE_URL>` |
| `SPRING_DATASOURCE_USERNAME` | `<STAGING_DB_USER>` | `<PROD_DB_USER>` |
| `SPRING_DATASOURCE_PASSWORD` | `<STAGING_DB_PASSWORD>` | `<PROD_DB_PASSWORD>` |
| `JWT_SECRET` | `<JWT_SECRET_STAGING>` | `<JWT_SECRET_PROD>` |
| `STRIPE_SECRET_KEY` | `<STRIPE_SECRET_KEY_TEST>` | `<STRIPE_SECRET_KEY_LIVE>` |
| `STRIPE_WEBHOOK_SECRET` | `<STRIPE_WEBHOOK_SECRET_STAGING>` | `<STRIPE_WEBHOOK_SECRET_PROD>` |
| `STRIPE_SUCCESS_URL` | `https://<STAGING_DOMAIN>/payment/success` | `https://<PROD_DOMAIN>/payment/success` |
| `STRIPE_CANCEL_URL` | `https://<STAGING_DOMAIN>/payment/cancel` | `https://<PROD_DOMAIN>/payment/cancel` |
| `JWT_ACCESS_MINUTES` | `15` (optional) | `15` (optional) |
| `JWT_REFRESH_DAYS` | `30` (optional) | `30` (optional) |

---

## 5) Stripe Webhook Setup + Test

### 5.1 Webhook URLs

| Environment | Webhook URL |
|-------------|-------------|
| **Staging** | `https://<STAGING_BASE_URL>/api/v1/payments/stripe/webhook` |
| **Production** | `https://<PROD_BASE_URL>/api/v1/payments/stripe/webhook` |

Example:
- Staging: `https://ayrnow-backend-staging.up.railway.app/api/v1/payments/stripe/webhook`
- Prod: `https://api.ayrnow.com/api/v1/payments/stripe/webhook`

### 5.2 Events to Enable

In Stripe Dashboard → Webhooks → Add endpoint → Select events:

- `checkout.session.completed`
- `payment_intent.succeeded`
- `payment_intent.payment_failed`

(Add others if your backend handles them.)

### 5.3 Test Staging Webhook with Stripe CLI

```bash
# 1. Login
stripe login

# 2. Forward webhooks to staging
stripe listen --forward-to https://<STAGING_BASE_URL>/api/v1/payments/stripe/webhook

# 3. CLI prints a signing secret (whsec_...). For local testing against staging,
#    you would normally use the CLI's secret. For staging itself, use the secret
#    from the Stripe Dashboard webhook you created for the staging URL.

# 4. Trigger test event
stripe trigger checkout.session.completed

# 5. Verify in CLI output: "Received event" and 200 response
```

### 5.4 Confirm Ledger Entry After Webhook

```bash
# 1. Create checkout session (needs valid unit + lease)
curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"unitId":"<UNIT_ID>","leaseId":"<LEASE_ID>","amountCents":1000}' \
  https://<STAGING_BASE_URL>/api/v1/payments/stripe/checkout-session

# 2. Complete payment in Stripe Checkout (or use test card 4242...)

# 3. After webhook fires, list ledger entries
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "https://<STAGING_BASE_URL>/api/v1/ledger/units/<UNIT_ID>?page=0&size=20"

# 4. Check balance
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "https://<STAGING_BASE_URL>/api/v1/balances/units/<UNIT_ID>"
```

---

## 6) Domain + HTTPS

### Railway

- Railway provides HTTPS on `*.up.railway.app` by default.
- **Custom domain:** Settings → Networking → Custom Domain → add `api.yourdomain.com`.
- Railway provisions and renews TLS automatically. No reverse proxy needed.

---

## 7) Smoke Test Checklist (Commands)

Replace placeholders: `<BASE_URL>`, `<ACCESS_TOKEN>`, `<USER_ID>`, `<PROPERTY_ID>`, `<UNIT_ID>`, `<LEASE_ID>`.

### 7.1 Health

```bash
curl -s https://<BASE_URL>/api/v1/health
# Expect: {"status":"ok"}
```

### 7.2 Register + Login

```bash
# Register
RESP=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"smoke@example.com","password":"securepass123","displayName":"Smoke User","role":"landlord","accountName":"Smoke Co"}' \
  https://<BASE_URL>/api/v1/auth/register)

# Extract token (jq)
ACCESS_TOKEN=$(echo "$RESP" | jq -r '.accessToken')
USER_ID=$(echo "$RESP" | jq -r '.userId')
ACCOUNT_ID=$(echo "$RESP" | jq -r '.accountId')

# Login (alternative)
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"smoke@example.com","password":"securepass123"}' \
  https://<BASE_URL>/api/v1/auth/login
```

### 7.3 Create Property

```bash
PROP_RESP=$(curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"name":"Smoke Property","address1":"123 Main","city":"Buffalo","state":"NY","postalCode":"14201"}' \
  https://<BASE_URL>/api/v1/properties)
PROPERTY_ID=$(echo "$PROP_RESP" | jq -r '.id')
```

### 7.4 Create Unit

```bash
UNIT_RESP=$(curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{"unitLabel":"101","status":"vacant"}' \
  "https://<BASE_URL>/api/v1/properties/<PROPERTY_ID>/units")
UNIT_ID=$(echo "$UNIT_RESP" | jq -r '.id')
```

### 7.5 Create Lease

```bash
LEASE_RESP=$(curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d "{\"unitId\":\"<UNIT_ID>\",\"tenantUserId\":\"<USER_ID>\",\"startDate\":\"2025-01-01\",\"endDate\":\"2025-12-31\"}" \
  https://<BASE_URL>/api/v1/leases)
LEASE_ID=$(echo "$LEASE_RESP" | jq -r '.id')
```

### 7.6 Create Checkout Session (Stripe)

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d "{\"unitId\":\"<UNIT_ID>\",\"leaseId\":\"<LEASE_ID>\",\"amountCents\":1000}" \
  https://<BASE_URL>/api/v1/payments/stripe/checkout-session
# Expect: checkoutSessionId, checkoutUrl
```

### 7.7 Ledger & Balances

```bash
# Ledger entries for unit
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "https://<BASE_URL>/api/v1/ledger/units/<UNIT_ID>?page=0&size=20"

# Balance for unit
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "https://<BASE_URL>/api/v1/balances/units/<UNIT_ID>"

# Balance for lease
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  "https://<BASE_URL>/api/v1/balances/leases/<LEASE_ID>"
```

---

## Quick Reference

| Step | Staging | Production |
|------|---------|------------|
| Railway project | Create project, add Postgres + service | New project, add Postgres + service |
| Branch | `main` or `develop` | `main` |
| Profile | `staging` | `prod` |
| Stripe keys | Test (`sk_test_`, `whsec_` for test webhook) | Live (`sk_live_`, `whsec_` for live webhook) |
| JWT_SECRET | Min 32 chars | Min 32 chars, unique from staging |
