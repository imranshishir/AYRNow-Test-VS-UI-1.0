# AYRNOW Flutter — Phase-2 (Architecture + Real UI)

Adds:
- Riverpod state management
- Core domain models (Rent, Ticket, Job, Approvals, User/Role)
- Mock repositories with realistic demo data
- Real UI for key MVP screens:
  - Landlord: L-12 Dashboard, L-23 Rent Board, L-30 Maintenance Inbox
  - Tenant:   T-06 Dashboard, T-10 Pay Rent
  - Contractor: C-10 Jobs Feed
  - Guard: S-10 Approvals Queue
- ALL other screens remain as placeholders (SpecScreen) but routes exist.

## Run

```bash
flutter pub get
flutter run
```

For iOS Simulator: `flutter run -d "iPhone 17 Pro"` (or your simulator name).

### Stripe PaymentSheet (TEST only)

- **Set Stripe publishable key for Flutter (test mode):**

  ```bash
  flutter run \
    --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_XXXXXXXXXXXXXXXXXXXXXXXX
  ```

- **Run backend with Stripe TEST secret:**
  - In `backend/.env` set `STRIPE_SECRET_KEY=sk_test_...`
  - Start backend from `backend/`:

  ```bash
  ./scripts/run_local.sh
  ```

- **Test tenant PaymentSheet flow (T-10 Pay Rent):**
  - Login as a tenant in the app.
  - Navigate: **T-06 Tenant Dashboard → T-10 Pay Rent → Pay with card**.
  - Backend will call `POST /v1/payments/intent` and return a `clientSecret` for Stripe PaymentSheet.

- **Stripe test card (TEST mode only):**
  - Card: `4242 4242 4242 4242`
  - Expiry: any future (e.g. `12/34`)
  - CVC: any 3 digits (e.g. `123`)
  - ZIP: `10001`

### Local dev with API backend

1. Start Postgres and the backend (see `backend/README_backend.md` and `backend/LOCAL_POSTGRES.md`).
2. Run the app. In **debug builds**, open **Settings (A-20)** to set **API Base URL** if needed:
   - **iOS Simulator:** Default is `http://127.0.0.1:8081`. If it doesn't reach the host, set `http://<your-mac-lan-ip>:8081`. Find Mac LAN IP: `ipconfig getifaddr en0` (Terminal) or System Settings → Network.
   - **Android emulator:** Default is `http://10.0.2.2:8081`.
   - Use **Save** to store the override, or **Reset to default** to clear it.

Generated: 2026-01-15 05:53
