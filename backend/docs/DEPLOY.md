# AYRNOW Backend Deployment Guide (Phase B13)

Deploy the backend to staging or production **without Docker**. Target: JVM (Java 17), port 8080.

---

## Required Environment Variables

| Variable | Local | Staging | Prod | Description |
|----------|-------|---------|------|--------------|
| `SPRING_PROFILES_ACTIVE` | `local` | `staging` | `prod` | Active Spring profile |
| `SPRING_DATASOURCE_URL` | optional (default: `jdbc:postgresql://localhost:5432/ayrnow_dev`) | **required** | **required** | PostgreSQL JDBC URL |
| `SPRING_DATASOURCE_USERNAME` | optional | **required** | **required** | DB username |
| `SPRING_DATASOURCE_PASSWORD` | optional | **required** | **required** | DB password |
| `JWT_SECRET` | optional (dev default) | **required** (min 32 chars) | **required** (min 32 chars) | HMAC key for JWT signing |
| `STRIPE_SECRET_KEY` | optional | **required** | **required** | Stripe API secret key (`sk_test_` or `sk_live_`) |
| `STRIPE_WEBHOOK_SECRET` | optional | **required** | **required** | Stripe webhook signing secret (`whsec_...`) |
| `STRIPE_SUCCESS_URL` | optional | optional (default in config) | optional (default in config) | Redirect after successful payment |
| `STRIPE_CANCEL_URL` | optional | optional | optional | Redirect if user cancels payment |
| `JWT_ACCESS_MINUTES` | optional (15) | optional | optional | Access token lifetime |
| `JWT_REFRESH_DAYS` | optional (30) | optional | optional | Refresh token lifetime |

**Production guardrails (fail-fast on startup):**
- `auth.dev-headers-enabled` must be `false` for staging/prod
- `JWT_SECRET` must be set and ≥ 32 chars
- `STRIPE_WEBHOOK_SECRET` and `STRIPE_SECRET_KEY` must be set

---

## PostgreSQL Setup

### Hosted PostgreSQL (recommended)

Use a managed provider: **Neon**, **Supabase**, **Railway**, **AWS RDS**, or **DigitalOcean Managed DB**.

1. Create a database and note the connection URL.
2. Ensure the DB user can create schema (Flyway will run migrations).
3. Set env vars:
   ```bash
   export SPRING_DATASOURCE_URL="jdbc:postgresql://host:5432/dbname?sslmode=require"
   export SPRING_DATASOURCE_USERNAME="user"
   export SPRING_DATASOURCE_PASSWORD="password"
   ```

### Flyway on Startup

Flyway is enabled by default. On first run, it will:
- Create all tables from migrations (`V1__init.sql` through latest)
- Apply any new migrations on subsequent deployments

No manual Flyway step required—start the app and Flyway runs automatically.

---

## Build and Run

### Build JAR

```bash
cd backend
./scripts/build_jar.sh
```

Or manually:

```bash
mvn clean package -DskipTests
```

Output: `target/ayrnow-backend-0.1.0-SNAPSHOT.jar`

### Run Locally

```bash
./scripts/run_local.sh
```

Uses `local` profile; DevAuth headers enabled. No JWT/Stripe required.

### Run Staging

```bash
export SPRING_DATASOURCE_URL="jdbc:postgresql://..."
export SPRING_DATASOURCE_USERNAME="..."
export SPRING_DATASOURCE_PASSWORD="..."
export JWT_SECRET="your-32-char-minimum-secret-key"
export STRIPE_SECRET_KEY="sk_test_..."
export STRIPE_WEBHOOK_SECRET="whsec_..."
./scripts/run_staging.sh
```

### Run Production (JAR)

```bash
export SPRING_PROFILES_ACTIVE=prod
# ... set all required env vars ...
java -jar target/ayrnow-backend-0.1.0-SNAPSHOT.jar
```

---

## systemd Service Example

Create `/etc/systemd/system/ayrnow-backend.service`:

```ini
[Unit]
Description=AYRNOW Backend API
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/opt/ayrnow
ExecStart=/usr/bin/java -jar /opt/ayrnow/ayrnow-backend.jar --spring.profiles.active=prod
Restart=on-failure
RestartSec=10

# Environment file (no secrets in this file; use env file with 0600)
EnvironmentFile=/opt/ayrnow/.env

[Install]
WantedBy=multi-user.target
```

Create `/opt/ayrnow/.env` (chmod 0600):

```
SPRING_PROFILES_ACTIVE=prod
SPRING_DATASOURCE_URL=jdbc:postgresql://...
SPRING_DATASOURCE_USERNAME=...
SPRING_DATASOURCE_PASSWORD=...
JWT_SECRET=...
STRIPE_SECRET_KEY=...
STRIPE_WEBHOOK_SECRET=...
STRIPE_SUCCESS_URL=https://yourapp.com/payment/success
STRIPE_CANCEL_URL=https://yourapp.com/payment/cancel
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable ayrnow-backend
sudo systemctl start ayrnow-backend
sudo systemctl status ayrnow-backend
```

---

## HTTPS (Reverse Proxy)

The app listens on HTTP (port 8080). Use a reverse proxy for HTTPS.

### Caddy (simplest)

```bash
# Install Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy

# Caddyfile (/etc/caddy/Caddyfile)
your-domain.com {
    reverse_proxy localhost:8080
}
```

Caddy auto-obtains and renews TLS certificates.

### Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /path/to/fullchain.pem;
    ssl_certificate_key /path/to/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Use Certbot for Let's Encrypt certificates.

---

## Stripe Webhooks (Staging)

### 1. Create Webhook in Stripe Dashboard

1. Go to Stripe Dashboard → Developers → Webhooks.
2. Add endpoint: `https://your-staging-domain.com/api/v1/payments/stripe/webhook`
3. Select events: `checkout.session.completed`, `payment_intent.succeeded`, etc.
4. Copy the signing secret (`whsec_...`) → `STRIPE_WEBHOOK_SECRET`.

### 2. Test Locally with Stripe CLI

```bash
# Install Stripe CLI: https://stripe.com/docs/stripe-cli
stripe login
stripe listen --forward-to localhost:8080/api/v1/payments/stripe/webhook
```

Use the `whsec_...` from the `listen` output as `STRIPE_WEBHOOK_SECRET` for local testing.

### 3. Staging Forward (Tunnel)

To test webhooks hitting staging from Stripe:

```bash
# Use ngrok or similar
ngrok http 8080
# Add ngrok URL as webhook endpoint in Stripe (e.g. https://abc.ngrok.io/api/v1/payments/stripe/webhook)
# Use the webhook signing secret for that endpoint
```

---

## Smoke Test Checklist (Manual)

Run these curl commands to verify deployment.

### 1. Health

```bash
curl -s https://your-domain.com/api/v1/health
# Expect: {"status":"ok"}
```

### 2. Auth (Register + Login)

```bash
# Register
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"smoke@example.com","password":"securepass123","displayName":"Smoke User","role":"landlord","accountName":"Smoke Co"}' \
  https://your-domain.com/api/v1/auth/register
# Save accessToken from response

# Login
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"smoke@example.com","password":"securepass123"}' \
  https://your-domain.com/api/v1/auth/login
# Expect: accessToken, refreshToken, userId, accountId, role
```

### 3. Create Property / Unit / Lease

```bash
TOKEN="<accessToken from above>"

# Create property
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Smoke Property","address1":"123 Main","city":"Buffalo","state":"NY","postalCode":"14201"}' \
  https://your-domain.com/api/v1/properties
# Save propertyId

# Create unit (replace {propertyId})
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d '{"unitLabel":"101","status":"vacant"}' \
  https://your-domain.com/api/v1/properties/{propertyId}/units
# Save unitId

# Create lease (replace {unitId}, use userId from login)
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d '{"unitId":"{unitId}","tenantUserId":"{userId}","startDate":"2025-01-01","endDate":"2025-12-31"}' \
  https://your-domain.com/api/v1/leases
# Save leaseId
```

### 4. Stripe Checkout Session (Staging)

```bash
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" \
  -d '{"unitId":"{unitId}","leaseId":"{leaseId}","amountCents":1000}' \
  https://your-domain.com/api/v1/payments/stripe/checkout-session
# Expect: checkoutSessionId, checkoutUrl
```

### 5. Webhook Endpoint Reachable (Stripe CLI)

```bash
stripe listen --forward-to https://your-staging-domain.com/api/v1/payments/stripe/webhook
# Trigger test event: stripe trigger checkout.session.completed
# Verify no 4xx/5xx in Stripe CLI
```

### 6. Ledger After Webhook

After a successful Stripe webhook processes a payment:

```bash
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://your-domain.com/api/v1/ledger/units/{unitId}?page=0&size=20"
# Expect: entries including the payment
```

---

## AWS EC2 + RDS (No Docker)

Deploy the backend JAR to EC2 with RDS PostgreSQL. No Docker required.

### RDS Postgres Creation

1. **RDS Console** → Create database
2. **Engine:** PostgreSQL 15
3. **Template:** Dev/Test or Production (Multi-AZ for prod)
4. **DB instance identifier:** `ayrnow-prod` (or similar)
5. **Credentials:** Set master username and password (store securely)
6. **Instance:** db.t3.micro (dev) or db.t3.small (prod)
7. **Storage:** 20 GB GP3
8. **Connectivity:**
   - **Public access:** Yes for quick setup (use private + bastion for hardened setups)
   - **VPC:** Default or your custom VPC
   - **Security group:** Create new or use existing (see below)
9. **Database name:** `ayrnow`
10. Create database. Note: endpoint, port (5432), username, password

### Security Groups

**RDS Security Group** (e.g. `ayrnow-rds-sg`):
- Inbound: Port **5432** from EC2 security group (source: `sg-xxxxxxxx`)
- Outbound: (default/all)

**EC2 Security Group** (e.g. `ayrnow-ec2-sg`):
- Inbound: Port **80** (HTTP), **443** (HTTPS) from 0.0.0.0/0
- Inbound: Port **22** (SSH) from your IP only
- Outbound: (default/all)

**Public vs private:** For production, prefer RDS in private subnet with no public access; EC2 in public subnet reaches RDS via VPC. For staging/dev, public RDS with restricted IP is acceptable.

### EC2 Setup (Ubuntu 22.04)

```bash
# 1. SSH into EC2
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>

# 2. Install Java 17
sudo apt update
sudo apt install -y openjdk-17-jdk

# 3. Verify
java -version
# openjdk 17.x.x

# 4. Create deploy user (recommended)
sudo useradd -m -s /bin/bash deploy
sudo usermod -aG sudo deploy  # or limit sudo as needed

# 5. Create app directory
sudo mkdir -p /opt/ayrnow
sudo chown deploy:deploy /opt/ayrnow

# 6. Copy JAR (from your build machine)
# scp -i your-key.pem backend/target/ayrnow-backend-0.1.0-SNAPSHOT.jar deploy@<EC2_IP>:/opt/ayrnow/ayrnow-backend.jar
```

### Systemd Service

Create `/etc/systemd/system/ayrnow-backend.service`:

```ini
[Unit]
Description=AYRNOW Backend API
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/opt/ayrnow
ExecStart=/usr/bin/java -jar /opt/ayrnow/ayrnow-backend.jar --spring.profiles.active=prod
Restart=on-failure
RestartSec=10

Environment=SPRING_PROFILES_ACTIVE=prod
Environment=SPRING_DATASOURCE_URL=jdbc:postgresql://<RDS_ENDPOINT>:5432/ayrnow?sslmode=require
Environment=SPRING_DATASOURCE_USERNAME=<DB_USERNAME>
Environment=SPRING_DATASOURCE_PASSWORD=<DB_PASSWORD>
Environment=JWT_SECRET=<JWT_SECRET>
Environment=STRIPE_SECRET_KEY=<STRIPE_SECRET_KEY>
Environment=STRIPE_WEBHOOK_SECRET=<STRIPE_WEBHOOK_SECRET>
Environment=STRIPE_SUCCESS_URL=https://api.yourdomain.com/payment/success
Environment=STRIPE_CANCEL_URL=https://api.yourdomain.com/payment/cancel

[Install]
WantedBy=multi-user.target
```

Use placeholders; replace with actual values. Alternatively, use `EnvironmentFile=/opt/ayrnow/.env` (chmod 0600) instead of inline `Environment=` lines.

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable ayrnow-backend
sudo systemctl start ayrnow-backend
sudo systemctl status ayrnow-backend
```

### Reverse Proxy + TLS (Caddy)

The app listens on port 8080. Use Caddy for HTTPS.

```bash
# Install Caddy (Ubuntu)
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy

# Caddyfile: /etc/caddy/Caddyfile
api.yourdomain.com {
    reverse_proxy localhost:8080
}
```

Reload Caddy: `sudo systemctl reload caddy`. Caddy obtains and renews TLS certificates automatically.

---

## Go Live Checklist

| Step | Action | Done |
|------|---------|------|
| 1 | Create production PostgreSQL DB | ☐ |
| 2 | Set all required env vars (no defaults for secrets) | ☐ |
| 3 | Run staging smoke tests (health, auth, property, unit, lease, Stripe checkout, webhook, ledger) | ☐ |
| 4 | Configure Stripe production webhook endpoint | ☐ |
| 5 | Use Stripe live keys (`sk_live_`, `whsec_` for live webhook) | ☐ |
| 6 | Build JAR: `./scripts/build_jar.sh` | ☐ |
| 7 | Deploy JAR to server | ☐ |
| 8 | Configure systemd (or equivalent) | ☐ |
| 9 | Configure HTTPS reverse proxy (Caddy/Nginx) | ☐ |
| 10 | Verify `/api/v1/health` returns OK | ☐ |
| 11 | Run full smoke test on production URL | ☐ |
| 12 | Monitor logs for errors | ☐ |
