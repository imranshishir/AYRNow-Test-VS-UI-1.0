# Frontend API Smoke Test Guide

How to verify the Flutter app connects to the AYRNOW backend successfully.

---

## 1. Run Backend Locally

See [documentation/backend/RUN_LOCAL.md](../backend/RUN_LOCAL.md) for full steps.

**Quick:**

```bash
cd backend
./scripts/run_local.sh
```

Verify:

```bash
curl -s http://localhost:8080/api/v1/health
# Expect: {"status":"ok"}
```

---

## 2. Base URL for Flutter

| Target | Base URL | Notes |
|--------|----------|-------|
| **Android emulator** | `http://localhost:8080` or `http://10.0.2.2:8080` | `10.0.2.2` is the host loopback on Android emulator |
| **iOS simulator** | `http://localhost:8080` or `http://127.0.0.1:8080` | Both work on simulator |
| **Physical device** | `http://<LAN_IP>:8080` | e.g. `http://192.168.1.100:8080` — backend and device must be on same network |

**Configure in code:** `lib/core/api/api_config.dart` — default is `http://localhost:8080`.  
Override at build: `flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8080`

**iOS App Transport Security (ATS):** For `http://` (non-HTTPS), add to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

(or use `NSExceptionDomains` for specific hosts only).

---

## 3. Curl: Register + Login (Confirm Backend)

```bash
# Register
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"smoke@test.com","password":"password123","displayName":"Smoke User","role":"landlord","accountName":"Smoke Account"}' \
  http://localhost:8080/api/v1/auth/register

# Expect: accessToken, refreshToken, userId, accountId, role

# Login (if already registered)
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"smoke@test.com","password":"password123"}' \
  http://localhost:8080/api/v1/auth/login

# Save accessToken, then list properties:
curl -s -H "Authorization: Bearer <ACCESS_TOKEN>" \
  http://localhost:8080/api/v1/properties
```

---

## 4. In-App Steps: Login → Properties Load

1. **Enable real API:** Feature flags default to `auth` + `properties` enabled in `lib/core/api/providers/feature_flags_provider.dart` (`FeatureFlags.authAndProperties`).

2. **Run Flutter app:**
   ```bash
   cd <project_root>
   flutter pub get
   flutter run
   ```

3. **Register or Login:**
   - Use the same email/password as in curl (e.g. `smoke@test.com` / `password123`)
   - Or register a new account

4. **Go to Properties:**
   - If landlord: navigate to Properties (from home/dashboard)
   - List should load from backend (or show empty if none created)
   - Add a property via backend curl or in-app (when wired) to verify create

5. **Fallback:** If network fails, properties show error state ("Could not load properties"). With mock flag, hardcoded list appears.

---

## 5. Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Connection refused | Backend not running | Start backend with `./scripts/run_local.sh` |
| 401 on /properties | Token missing/expired | Re-login; ensure Auth feature flag is on |
| iOS "insecure" / ATS | HTTP blocked | Add `NSAppTransportSecurity` to Info.plist |
| Android emulator cannot reach localhost | Emulator network | Use `http://10.0.2.2:8080` instead of localhost |
| Physical device cannot reach backend | Different network | Use machine LAN IP; ensure firewall allows 8080 |

---

## Related Docs

- [backend_integration_plan.md](backend_integration_plan.md) — Full integration plan
- [documentation/backend/API_TESTING.md](../backend/API_TESTING.md) — Backend curl reference
