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
flutter create ayrnow_app
Copy this repo’s `pubspec.yaml`, `analysis_options.yaml`, and `lib/` into your new app folder.
flutter pub get
flutter run

Generated: 2026-01-15 05:53
