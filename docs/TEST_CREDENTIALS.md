# AYRNOW test credentials (simulator / local)

Use these to log in when the **backend is running locally** (e.g. `cd backend && ./scripts/run_local.sh`).

## Dev login (DevLoginSeeder – recommended)

These accounts are created or updated on every backend start when not in prod:

| Role     | Email              | Password   |
|----------|--------------------|------------|
| Landlord | **landlord@demo.com** | **ayrnow123** |
| Tenant   | **tenant@demo.com**   | **ayrnow123** |

## Simulator setup

- **iOS Simulator:** App uses `127.0.0.1:8081` by default, so the simulator can reach the backend on your Mac.
- **Android Emulator:** App uses `10.0.2.2:8081` by default.
- Backend default port: **8081** (see `backend/scripts/run_local.sh`).

## Quick test

1. Start backend: `cd backend && ./scripts/run_local.sh`
2. Run app: `flutter run -d "iPhone 17 Pro"` (or your simulator name)
3. On login screen enter **landlord@demo.com** / **ayrnow123** (or tenant) and tap Sign in.
