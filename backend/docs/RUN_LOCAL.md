# Run Locally — AYRNOW Backend

Exact steps to run the backend on your machine. No Docker.

---

## Run Local (5 Minutes) — Smoke Test Checklist

| Step | Command | Expected |
|------|---------|----------|
| 1. Start Postgres | Ensure PostgreSQL is running locally | `psql -U postgres -c "SELECT 1"` works |
| 2. Reset DB | `./scripts/reset_local_db.sh` | "OK: Database ayrnow_dev dropped and recreated" |
| 3. Run backend | `./scripts/run_local.sh` or `SPRING_PROFILES_ACTIVE=local mvn spring-boot:run` | "Started AyrnowBackendApplication" |
| 4. Verify health | `curl -s http://localhost:8080/api/v1/health` | `{"status":"ok"}` |
| 5. Login | `curl -s -X POST -H "Content-Type: application/json" -d '{"email":"test@test.com","password":"test123"}' http://localhost:8080/api/v1/auth/login` | Returns `accessToken` |
| 6. Create property | `curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <TOKEN>" -d '{"name":"Test Property","city":"Buffalo"}' http://localhost:8080/api/v1/properties` | Returns property JSON |
| 7. Create unit | `curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <TOKEN>" -d '{"propertyId":"<PROP_ID>","unitLabel":"101"}' http://localhost:8080/api/v1/units` | Returns unit JSON |

**One-shot reset + start:** `./scripts/reset_local_db.sh --start`

**Check Flyway versions (no duplicates):** `./scripts/check_flyway_versions.sh`

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

## Flyway (Local Profile)

- Flyway runs automatically on startup (`spring.flyway.enabled=true`).
- **Production:** `classpath:db/migration` only (`src/main/resources/db/migration/`).
- **Local profile:** `classpath:db/migration` + `classpath:db-local` (`src/main/resources/db-local/`).
- V99 (`db-local/V99__dev_reset_and_seed.sql`) runs only in local: truncates domain data and seeds a correlated dev dataset.
- V100 adds the test account; after boot, **`test@test.com` / `test123`** exists for login.

### Reset DB cleanly

```bash
dropdb ayrnow_dev
createdb ayrnow_dev
```

Then restart the app. Flyway will run all migrations from scratch. (`flyway clean` is not enabled by default; dropdb/createdb is the standard approach.)

---

## Local Auth Modes

### A) JWT Flow (recommended)

**Test login:** `test@test.com` / `test123`. Use "Use test account" on login screen (debug build) or curl below.

1. Login with test account:
   ```bash
   curl -s -X POST -H "Content-Type: application/json" \
     -d '{"email":"test@test.com","password":"test123"}' \
     http://localhost:8080/api/v1/auth/login
   ```

   Or register a new user:
   ```bash
   curl -s -X POST -H "Content-Type: application/json" \
     -d '{"email":"dev@local.test","password":"password123","displayName":"Dev User","role":"landlord","accountName":"Dev Account"}' \
     http://localhost:8080/api/v1/auth/register
   ```
3. Use `accessToken` from response:
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

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| `psql: command not found` | PostgreSQL client not in PATH | Add PostgreSQL `bin` to PATH, or use GUI (pgAdmin, DBeaver). |
| Port 8080 already in use | Another process on 8080 | `lsof -i :8080` → kill process, or `PORT=8081 ./scripts/run_local.sh`. |
| 401 on /api/v1/health | DevAuth requiring headers | Health is permitAll; ensure DevAuthFilter skips `/api/v1/health` (fixed in security config). |
| Flyway duplicate versions | V99 in both db/migration and db-local | Run `./scripts/check_flyway_versions.sh`. Keep V99 only in `db-local`; local profile uses `db/migration` + `db-local`. |
| `JWT_SECRET must be set` | Running with staging/prod profile | Use `SPRING_PROFILES_ACTIVE=local`, or set `JWT_SECRET` (min 32 chars). |
| `Invalid token` / 401 | Expired or malformed JWT | Re-login to get new `accessToken`. |
| Stripe webhook fails locally | Webhook URL must be reachable | Use Stripe CLI: `stripe listen --forward-to localhost:8080/api/v1/payments/stripe/webhook`. Use the printed `whsec_...` as `STRIPE_WEBHOOK_SECRET`. |
| Flyway validation failed | Schema mismatch | Drop DB and recreate: `dropdb ayrnow_dev && createdb ayrnow_dev`. Re-run app. |
| Migration checksum mismatch (V99) | DB was migrated with old V99 copy | `dropdb ayrnow_dev && createdb ayrnow_dev`. Re-run app. |
| `mvn: command not found` | Maven not installed | Install Maven 3.8+ or use SDKMAN: `sdk install maven`. |

---

## Quick Commands

```bash
# Run
./scripts/run_local.sh

# Build JAR only
./scripts/build_jar.sh

# Health check
curl -s http://localhost:8080/api/v1/health

# Swagger UI
open http://localhost:8080/swagger-ui.html
```
