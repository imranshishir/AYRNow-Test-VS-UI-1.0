# AYRNOW AWS Deployment Runbook

**No Docker in local AYRNOW workflow.** This runbook assumes deploying the Spring Boot backend to AWS (e.g. EC2, ECS, or Elastic Beanstalk) and optional Flutter app hosting (e.g. S3+CloudFront for web).

---

## 1. Prerequisites

- AWS account; CLI configured.
- Backend: Java 17, Spring Boot 3.2; built with `./gradlew build` (produces JAR).
- Database: PostgreSQL (e.g. RDS).
- Secrets: JWT_SECRET, DB credentials, Stripe keys in AWS Secrets Manager or Parameter Store (not in repo).

---

## 2. Database (RDS)

- Create PostgreSQL instance (private subnet recommended).
- Create database and user; note endpoint, port, DB name, username, password.
- Store credentials in Secrets Manager; or set env vars on backend host/container.
- Run Flyway migrations: either at deploy time (e.g. `java -jar app.jar` with spring.flyway.enabled=true and DB_URL) or one-time migration job.

---

## 3. Backend deployment options

### Option A: EC2

- Launch Amazon Linux 2 (or similar); Java 17 installed.
- Copy JAR (e.g. from S3 or build artifact).
- Set env: DB_URL, DB_USER, DB_PASSWORD, JWT_SECRET, SERVER_PORT=8080, SPRING_PROFILES_ACTIVE=prod. Stripe keys if using payments.
- Run: `java -jar ayrnow-backend.jar`.
- Use systemd or supervisor to keep process running.
- Put behind ALB; HTTPS via ALB or ACM certificate.

### Option B: ECS (Fargate)

- Build JAR; push image to ECR (or use Dockerfile that only runs JAR; no Docker in *local* workflow, but ECS can run containerized JAR).
- Task definition: env from Secrets Manager or Parameter Store.
- RDS in VPC; ECS tasks in private subnet; ALB in public subnet.
- Health check: GET /api/v1/health or /v1/health (match backend).

### Option C: Elastic Beanstalk

- Upload JAR or use build spec to produce JAR.
- Configure env in EB console (or .env.ebextensions); link RDS.
- Use single instance or LB; enable HTTPS.

---

## 4. Configuration

- **SPRING_PROFILES_ACTIVE=prod** (or staging).
- **application-prod.yml** (or env vars): datasource URL, JWT, Stripe, CORS (allowed-origins for Flutter app domain).
- **Stripe webhook:** In Stripe Dashboard set webhook URL to https://your-api-domain.com/v1/webhooks/stripe (or the path your backend exposes). Use STRIPE_WEBHOOK_SECRET in backend.

---

## 5. Health and networking

- Backend port (e.g. 8080) open to ALB only (not 0.0.0.0/0).
- ALB listener 443 → backend:8080; ACM cert for API domain.
- Health path allowed in security group / target group.

---

## 6. Post-deploy

- Call GET /api/v1/health or /v1/health to confirm.
- Run smoke tests: login, property list, invite create (and payments if configured).
- Point Flutter production build at this API base URL (see ENVIRONMENT_VARIABLES.md and MOBILE_RELEASE_RUNBOOK.md).

---

## 7. No Docker note

Local development uses `./gradlew bootRun` and `flutter run` without Docker. This runbook does not require Docker for local workflow; only deployment target (EC2/ECS/EB) and how you run the JAR matter.
