# Pedido Local Frontend Plan

## Goal

Build a mobile-first Flutter customer app in the existing `/frontend` directory while keeping
the FastAPI backend as the source of truth for authentication, catalog data, and orders. The
visual direction should follow the supplied food-ordering screenshots: green brand header,
compact mobile layout, product cards, cart/checkout flow, and order-tracking presentation.

The first implementation milestone is real API core plus local presentation placeholders. The
backend will power auth, categories, products, cart-to-order submission, order list, order
detail, and cancellation. Screenshot-only features such as product images, ratings, promo
content, coupons, and map tracking remain local UI placeholders until the backend exposes
those concepts.

## Current State

- `/frontend` contains a Flutter scaffold created by an earlier attempt.
- `main.dart` now boots `PedidoLocalApp` with app theme, routes, repositories, and providers.
- Splash, auth, home, product detail, cart, orders, tracking, and profile screens exist as
  customer-facing route targets.
- API helpers, repositories, models, and providers are wired for auth, catalog, cart, and orders.
- Auth forms call `/auth/register`, `/auth/token`, and `/auth/me`.
- Home loads real categories/products from `/categories` and `/products`, then filters locally.
- Cart checkout submits real `/orders` payloads using backend payment enum values.
- Orders and tracking screens call `/orders`, `/orders/{id}`, and `/orders/{id}/cancel`.
- Customer screens now follow the supplied food-ordering reference more closely: branded splash,
  green location/search header, promo banner, product cards, quantity-aware product detail,
  checkout summary, order status chips, static map-like tracking, and status timeline.
- User-facing mojibake has been removed from the foundation screens and primary reusable widgets.
- `pubspec.yaml` declares the required foundation packages.
- `pubspec.lock` has been regenerated after dependency updates.
- Flutter and Dart are available at `C:\flutter\bin`, but they are not currently on this shell's
  `PATH`.

## Implementation Milestones

### 1. Documentation and Monorepo Alignment

- Keep this planning document in `/frontend/DOCUMENTATION.md`.
- Update root documentation so the project is described as a backend-plus-Flutter monorepo.
- Keep frontend generated files, caches, and IDE metadata out of reviewable diffs.

### 2. Backend Docker Runtime

- Backend Docker runtime lives in `backend/Dockerfile`, `backend/docker-entrypoint.sh`, and
  root `docker-compose.yml`.
- The image uses Python 3.13 slim, installs from `pyproject.toml`, copies Alembic migrations,
  and runs the app as a non-root `appuser`.
- SQLite is persisted in the `backend_data` Docker volume at `/app/data/pedidolocal.db`.
- Startup applies `alembic upgrade head`, then runs Uvicorn on `0.0.0.0:8000`.
- The image healthcheck calls `/health`.

### 3. Flutter Foundation Cleanup

- `PedidoLocalApp` is the real entrypoint.
- Theme, routes, app-level providers, repositories, secure token storage, and API configuration
  are wired.
- Required dependencies are declared: `http`, `provider`, `flutter_secure_storage`, and `intl`.
- The structure is split into core, models, repositories, providers, screens, and widgets.
- Minimal route-target screens exist so future feature work can focus on behavior and UI polish
  instead of repairing missing imports.

### 4. API Integration

The Flutter app uses the existing backend API contract without schema changes for v1:

- `POST /auth/register`
- `POST /auth/token`
- `GET /auth/me`
- `GET /categories`
- `GET /products`
- `POST /orders`
- `GET /orders`
- `GET /orders/{id}`
- `POST /orders/{id}/cancel`

The Flutter API base URL should be configurable with:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Default to `http://10.0.2.2:8000` for Android emulator access to the Dockerized backend.

Implemented integration behavior:

- Login posts form credentials to `/auth/token`, stores the bearer token securely, and fetches
  `/auth/me`.
- Registration posts customer data to `/auth/register`, then logs in with the created account.
- Catalog loading fetches `/categories` and `/products`; search and category filtering are local
  because backend filtering is not part of the current contract.
- Cart checkout requires an authenticated customer and posts `items`, `payment_method`,
  `delivery_city`, and `delivery_address` to `/orders`.
- Order list, tracking refresh, and cancellation use the authenticated order endpoints.

### 5. Customer Screens

Implemented customer-screen behavior:

- Splash/onboarding screen with the Pedido Local logo and a `Comecar agora` action.
- Login and registration screens aligned with backend auth fields.
- Home catalog with location header, search, category chips, promo banner, product grid, and
  bottom navigation.
- Product detail screen with a local image/fallback visual, description, price, stock state,
  quantity selection, computed total, and add-to-cart action.
- Cart and checkout screen with quantity editing, delivery city/address, backend-supported
  payment methods, order summary, unauthenticated checkout prompt, and order submission.
- Orders and tracking screens with order status chips, status timeline, static local map-like
  visual, refresh, and cancellation where the backend allows it.

## V1 Boundaries

- Do not add Android Studio, desktop mode, or IDE-driven workflows to the implementation path.
- Do not add external cloud services, payment providers, push notifications, or live map SDKs.
- Do not fake backend persistence for real business concepts.
- Keep product images, ratings, promos, coupons, delivery ETA, and route map details as local UI
  placeholders until backend contracts exist.
- Keep all behavior changes covered by tests and documentation.

## Validation

Backend validation from `/backend`:

```powershell
.\.venv\Scripts\python -m pytest --cov=app --cov-report=term-missing
.\.venv\Scripts\python -m ruff check .
.\.venv\Scripts\python -m alembic upgrade head
```

Docker validation after the Docker step:

```powershell
docker compose up --build
```

Then verify:

- `GET http://127.0.0.1:8000/health`
- Alembic migrations applied successfully.
- A customer can register, log in, browse products, create an order, and view that order against
  the live SQLite database volume.

Frontend validation from `/frontend` once Flutter is available:

```powershell
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

In the current local environment, use `C:\flutter\bin\flutter.bat` and
`C:\flutter\bin\dart.bat` because Flutter is not on `PATH`.

Implemented frontend tests:

- JSON parsing for auth, user, category, product, cart item, and order models.
- API client success and error mapping.
- Auth provider token persistence and logout behavior.
- Cart totals, quantity limits, and order payload construction.
- Widget tests for splash, home loading/success/error states, product detail, checkout
  submission, and order tracking display.

## Assumptions

- The app is customer-facing for v1; admin catalog management remains backend/API-only.
- The supplied screenshots are visual inspiration, not exact backend feature requirements.
- The backend remains local-first with SQLite.
- The existing `/frontend` code can be refactored or removed when it is broken, but useful
  model/widget intent should be preserved where practical.
