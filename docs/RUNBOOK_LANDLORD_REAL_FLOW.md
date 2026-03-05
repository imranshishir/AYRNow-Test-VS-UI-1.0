# Landlord MVP Real Flow (Local Dev)

## Prereqs

- Backend running locally on port **8081**
- Flutter app configured with `API_BASE_URL` pointing to `http://127.0.0.1:8081`

### Start backend

```bash
cd backend
./gradlew bootRun
```

Health check:

```bash
curl http://127.0.0.1:8081/actuator/health
```

## Key API endpoints (backend)

- `POST /v1/auth/login`
- `GET /v1/me`
- `GET /v1/properties`
- `POST /v1/properties`
- `GET /v1/properties/{propertyId}/units`
- `POST /v1/properties/{propertyId}/units`
- `POST /v1/units/{unitId}/invites`

### cURL examples

Login (landlord):

```bash
curl -X POST http://127.0.0.1:8081/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"landlord@demo.com","role":"landlord"}'
```

List properties:

```bash
curl -H "Authorization: Bearer <TOKEN>" \
  http://127.0.0.1:8081/v1/properties
```

Create property:

```bash
curl -X POST http://127.0.0.1:8081/v1/properties \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"name":"Demo Property","address":"123 Main St"}'
```

List units for a property:

```bash
curl -H "Authorization: Bearer <TOKEN>" \
  http://127.0.0.1:8081/v1/properties/<PROPERTY_ID>/units
```

Create unit for a property:

```bash
curl -X POST http://127.0.0.1:8081/v1/properties/<PROPERTY_ID>/units \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"name":"Unit 1A"}'
```

Create unit invite:

```bash
curl -X POST http://127.0.0.1:8081/v1/units/<UNIT_ID>/invites \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"email":"tenant@example.com"}'
```

## Flutter run (iOS simulator)

From repo root:

```bash
flutter pub get
flutter run -d "iPhone 17 Pro" \
  --dart-define=API_BASE_URL=http://127.0.0.1:8081 \
  --dart-define=API_BASE_URL_ANDROID=http://10.0.2.2:8081
```

## In-app landlord flow

1. Login as landlord (e.g., `landlord@demo.com`).
2. Open **Properties** from the L-12 Landlord Dashboard (navigates to **L-25**).
3. Tap **Add property** (FAB) to open **L-20**, create a real property.
4. From L-25, tap a property to open **L-22** and view its units.
5. From L-22, tap **Add unit** (FAB) to open **L-21**, create a real unit.
6. From L-22, tap a unit row to open **L-24** Unit Detail.
7. From L-24, open **Residents & Family** to reach **L-50**.
8. From L-50, tap **Invite member** to open **T-50/invite**, create a backend-backed invite; the returned token/code is shown in the bottom sheet.
