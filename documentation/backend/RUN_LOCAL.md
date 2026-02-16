# Run Locally — AYRNOW Backend

Exact steps to run the backend on your machine. No Docker.

---

## Prerequisites

| Tool | Version | How to check |
|------|---------|--------------|
| Java | 17+ | `java -version` |
| Maven | 3.8+ | `mvn -v` |
| PostgreSQL | 15+ | `psql --version` |

---

## Create DB + Run App

### 1. Create Database

```bash
# If PostgreSQL is running locally:
createdb ayrnow_dev

# Or via psql:
psql -U postgres -c "CREATE DATABASE ayrnow_dev;"
```

Default DB name: `ayrnow_dev`. Override with `SPRING_DATASOURCE_URL`.

### 2. Run Application

```bash
cd backend
./scripts/run_local.sh
```

Or manually:

```bash
cd backend
export SPRING_PROFILES_ACTIVE=local
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/ayrnow_dev
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=
mvn spring-boot:run
```

### 3. Verify

```bash
curl -s http://localhost:8080/api/v1/health
# {"status":"ok"}
```

---

## Flyway Expectations

- Flyway runs automatically on startup (`spring.flyway.enabled=true`).
- Migrations: `backend/src/main/resources/db/migration/V*.sql`.
- On first run: Creates all tables (accounts, users, properties, units, leases, etc.).
- V2 seed: Inserts dev account + user for DevAuth headers.
- Subsequent runs: Applies any new migrations. No manual Flyway command needed.

---

## Local Auth Modes

### A) JWT Flow (recommended)

1. Register:
   ```bash
   curl -s -X POST -H "Content-Type: application/json" \
     -d '{"email":"dev@local.test","password":"password123","displayName":"Dev User","role":"landlord","accountName":"Dev Account"}' \
     http://localhost:8080/api/v1/auth/register
   ```
2. Use `accessToken` from response:
   ```bash
   curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" http://localhost:8080/api/v1/properties
   ```

### B) DevAuth Headers (local only)

When `SPRING_PROFILES_ACTIVE=local`, you can use headers instead of JWT:

```bash
curl -s -H "X-Dev-AccountId: aaaaaaaa-0000-0000-0000-000000000001" \
     -H "X-Dev-UserId: bbbbbbbb-0000-0000-0000-000000000001" \
     -H "X-Dev-Role: landlord" \
     http://localhost:8080/api/v1/properties
```

These IDs come from V2 seed (`V2__dev_seed.sql`). DevAuth is disabled in staging/prod.

---

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| `psql: command not found` | PostgreSQL client not in PATH | Add PostgreSQL `bin` to PATH, or use GUI (pgAdmin, DBeaver). |
| Port 8080 already in use | Another process on 8080 | `lsof -i :8080` → kill process, or set `server.port=8081` via env or `--server.port=8081`. |
| `JWT_SECRET must be set` | Running with staging/prod profile | Use `SPRING_PROFILES_ACTIVE=local`, or set `JWT_SECRET` (min 32 chars). |
| `Invalid token` / 401 | Expired or malformed JWT | Re-login to get new `accessToken`. |
| Stripe webhook fails locally | Webhook URL must be reachable | Use Stripe CLI: `stripe listen --forward-to localhost:8080/api/v1/payments/stripe/webhook`. Use the printed `whsec_...` as `STRIPE_WEBHOOK_SECRET`. |
| Flyway validation failed | Schema mismatch | Drop DB and recreate: `dropdb ayrnow_dev && createdb ayrnow_dev`. Re-run app. |
| `mvn: command not found` | Maven not installed | Install Maven 3.8+ or use SDKMAN: `sdk install maven`. |

---

## Quick Commands

```bash
# Run
cd backend && ./scripts/run_local.sh

# Build JAR only
cd backend && ./scripts/build_jar.sh

# Health check
curl -s http://localhost:8080/api/v1/health

# Swagger UI
open http://localhost:8080/swagger-ui.html
```
