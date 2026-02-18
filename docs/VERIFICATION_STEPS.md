# Local Verification Steps

## 1. Run backend (local profile)

```bash
# Ensure Postgres is running with ayrnow_dev database
dropdb ayrnow_dev 2>/dev/null; createdb ayrnow_dev

cd backend
export SPRING_PROFILES_ACTIVE=local
mvn spring-boot:run
```

Wait until: `Started AyrnowBackendApplication`. Flyway applies migrations (V100 seeds test@test.com).

## 2. Login from app with test@test.com / test123

1. Run Flutter app on iOS simulator: `./scripts/run_simulator.sh` or `flutter run -d ios`
2. On login screen, tap **"Use test account"** (only visible in debug build) to fill test@test.com / test123
3. Tap **Log in**
4. Choose **Landlord** role if prompted
5. You should land on the home/dashboard

## 3. Create Property from UI

1. Navigate to **Properties** (or Add Property from dashboard)
2. Tap **Add property** (FAB)
3. Fill: Property name (e.g. "My New Property"), City (optional)
4. Tap **Save property**

## 4. Immediately see it in the property list

- The new property should appear in the list **without** restarting the app
- If you see mock data (Harlem Heights, etc.) instead, ensure feature flags have `properties: true` (default with authAndProperties)

## 5. Kill/reopen app → property still shows

1. Force-quit the Flutter app
2. Reopen the app
3. Login again with test@test.com / test123
4. Navigate to Properties
5. The property you created should still be there (persisted on server)

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Login fails "Invalid email or password" | Ensure backend ran migrations; V100 seeds test@test.com (in db/migration) |
| Properties list shows mock data | Feature flags use `authAndProperties` which enables properties. Check `lib/core/api/providers/feature_flags_provider.dart` |
| Create succeeds but list doesn't update | Ensure `ref.invalidate(propertiesListProvider)` is called after create in `LlAddPropertyScreen` |
| Connection refused / timeout | Use `http://127.0.0.1:8080` for iOS simulator (default in `ApiConfig`). For Android emulator use `http://10.0.2.2:8080` via `--dart-define=API_BASE_URL=...` |
