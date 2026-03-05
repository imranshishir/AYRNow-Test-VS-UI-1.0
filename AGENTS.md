# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

AYRNOW is a Flutter mobile/web/desktop property management app (Phase-2 MVP scaffold). It uses Riverpod for state management and runs entirely on mock/in-memory data — no backend, database, or external services are required.

### Flutter SDK

Flutter SDK 3.32.8 (Dart 3.8.1) is installed at `/opt/flutter/bin`. The PATH is configured in `~/.bashrc`. If `flutter` is not found, run `export PATH="/opt/flutter/bin:$PATH"`.

### Common commands

| Task | Command |
|---|---|
| Install deps | `flutter pub get` |
| Lint / analyze | `flutter analyze` |
| Run tests | `flutter test` |
| Run web (dev) | `flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0` |
| Build web | `flutter build web` |

### Gotchas

- The `assets/icons/` directory referenced in `pubspec.yaml` may not exist; create it (`mkdir -p assets/icons`) if `flutter analyze` warns about it.
- Check for stray git merge conflict markers before building — the repo has had them in `lib/core/state/providers.dart`.
- The app uses hash-based routing for Flutter web (URLs like `localhost:8080/#/home`, `localhost:8080/#/L-23`).
- `flutter run -d web-server` starts a debug web server but does not open a browser; navigate to `http://localhost:8080` manually or via `computerUse` subagent.
- All data is mock — no authentication, no API keys, no database setup needed.
- New screen files under `lib/features/` must be imported and registered in `lib/navigation/routes.dart` (via `routes['/ROUTE-ID'] = (_) => const ScreenWidget();`) to become navigable. The fallback `SpecScreen` placeholders use `putIfAbsent`, so explicit route entries always take priority.
- The app serves a static build via `flutter build web`; for hot-reload during development, use `flutter run -d web-server` instead.
