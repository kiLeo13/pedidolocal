# Pedido Local Frontend

Flutter mobile customer app for Pedido Local.

This directory is part of the Pedido Local monorepo. It should contain only frontend code,
assets, tests, and Flutter-specific configuration. The FastAPI backend remains in `/backend`.

## Current Status

This frontend now has a customer-facing Flutter flow plus real API integration for auth,
catalog, cart checkout, order listing, tracking refresh, and cancellation. The current UI
includes the branded splash, location/search catalog, product detail quantity selection,
checkout summary, order list, and static local tracking timeline described in
`DOCUMENTATION.md`.

## Local Commands

Flutter must be available on `PATH`.

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Use `API_BASE_URL=http://10.0.2.2:8000` when running on an Android emulator against the local
Dockerized backend.
