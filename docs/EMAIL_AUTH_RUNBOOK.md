# AYRNOW Email Auth Runbook

Email verification and password reset using Amazon SES. No secrets in repo; all config via env.

---

## 1. Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| AWS_REGION | Yes (when using SES) | SES region, e.g. us-east-1 |
| SES_FROM_EMAIL | Yes (to send emails) | Verified sender address in SES |
| SES_FROM_NAME | No | Display name, default AYRNOW |
| APP_BASE_URL | Yes | Base URL for links in emails; **use HTTPS in production** |

See ENVIRONMENT_VARIABLES.md for full list. Never commit these; use backend/.env locally or AWS Secrets Manager / Parameter Store in production.

---

## 2. Backend endpoints

| Method | Path | Purpose |
|--------|------|--------|
| POST | /v1/auth/register | Create user (emailVerified=false), send verification email, return 201 { message, emailSent } |
| POST | /v1/auth/verify-email | Body: { "token": "..." }. Mark user verified; 204 or 401 |
| POST | /v1/auth/forgot-password | Body: { "email": "..." }. Send reset email if user exists; always 204 (no user enumeration) |
| POST | /v1/auth/reset-password | Body: { "token": "...", "newPassword": "..." }. Set new password, invalidate token; 204 or 401 |
| POST | /v1/auth/login | Blocked if emailVerified=false; returns 401 with message "Please verify your email before signing in." |

Verification and reset tokens are hashed (SHA-256) in DB; raw tokens are never logged. Rate limit: 5 attempts per 15 minutes per IP for verify-email and forgot-password.

---

## 3. Data model (users table)

- email_verified (boolean, default false for new signups)
- verification_token_hash, verification_token_expires_at (nullable)
- reset_token_hash, reset_token_expires_at (nullable)

Migration: base/V26__email_verification_and_reset.sql. Existing users are updated to email_verified=true so they can still log in.

---

## 4. Local test steps (without SES)

1. Set in backend/.env: JWT_SECRET (min 32 chars), DB_*; leave SES_FROM_EMAIL empty.
2. Run backend: `./scripts/run_local.sh` (or `./gradlew bootRun` with profile local).
3. Run Flutter: `flutter run -d chrome` or device; set API base URL to backend (e.g. http://localhost:8081).
4. **Register:** Create account → API returns 201, no email sent (SES not configured). User is created with emailVerified=false.
5. **Verify without email:** Use DB or a test endpoint to get a verification token, or temporarily in AuthService log the raw token (dev only) and paste it in the Verify Email screen. Or run SQL: `UPDATE users SET email_verified = true WHERE email = 'test@test.com';` then log in.
6. **Login (unverified):** Try to log in before verifying → 401 "Please verify your email before signing in."
7. **Verify (with token):** Open Verify Email screen, paste token (if you have one), Submit → 204, then log in works.
8. **Forgot password:** Submit email → 204 (no email sent if SES empty). To test reset without email: set reset_token_hash and reset_token_expires_at in DB from a token you generate (e.g. via a temporary dev endpoint or TokenHashUtil in a test).
9. **Reset password:** Open Reset Password screen, paste token and new password → 204, then log in with new password.

---

## 5. Local test steps (with SES)

1. Verify sender in SES (Sandbox or production): add and verify SES_FROM_EMAIL.
2. Set AWS_REGION, SES_FROM_EMAIL, SES_FROM_NAME, APP_BASE_URL in backend/.env. For local links use a tunnel (e.g. ngrok) or a placeholder; app can open verify/reset screens with token from email link (copy token from URL).
3. Register with a real email → check inbox for verification link. Link format: {APP_BASE_URL}/verify-email?token=...
4. Click link (or copy token into app Verify Email screen) → verify → log in.
5. Forgot password → check inbox for reset link. Link format: {APP_BASE_URL}/reset-password?token=...
6. Click link (or copy token into app Reset Password screen), set new password → log in with new password.

---

## 6. Production test steps

1. **SES:** Use production SES or leave sandbox; verify sender domain/email. Set AWS_REGION, SES_FROM_EMAIL, SES_FROM_NAME in deployment env.
2. **APP_BASE_URL:** Set to production app URL (HTTPS), e.g. https://app.ayrnow.com. All links in emails must be HTTPS.
3. **Register:** New user → 201, email sent. User cannot log in until verified.
4. **Verify:** User clicks link in email (or opens app via deep link with token) → verify-email → 204 → user can log in.
5. **Login (unverified):** Must return 401 with clear message; no token.
6. **Forgot password:** Submit email → 204 always (same response if email not found). Check inbox for reset link.
7. **Reset password:** Use link or paste token in app → set new password → 204 → log in with new password.
8. **Rate limit:** Trigger 6+ verify or forgot-password requests from same IP in 15 min → 429.

---

## 7. Flutter routes

- `/verify-email` – Verify Email screen (arguments: email, message; or token for deep link).
- `/reset-password` – Reset Password screen (arguments: token when opened via link).

Deep link: configure app to handle URLs like `https://app.ayrnow.com/verify-email?token=xxx` and `https://app.ayrnow.com/reset-password?token=xxx`; pass token to the screen and prefill or auto-submit when appropriate.

---

## 8. Security checklist

- [ ] No raw tokens in logs (backend never logs token values).
- [ ] Tokens stored only as SHA-256 hash in DB.
- [ ] Forgot-password response identical whether email exists or not (no user enumeration).
- [ ] APP_BASE_URL is HTTPS in production.
- [ ] Rate limiting enabled for verify-email and forgot-password.
- [ ] Verification and reset tokens expire (24h and 1h respectively).
