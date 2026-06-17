# Pedido Local Presentation

## 1. Project Summary

Pedido Local is a local-first ordering and delivery platform built as a monorepo. It contains a
FastAPI backend and a Flutter mobile frontend. The project is designed for a small local business
or local delivery operation where customers can register, browse a catalog, place orders, track
order status, and cancel eligible orders.

The current version is an MVP. It intentionally avoids external cloud services, payment gateways,
push notifications, live map providers, object storage, or multi-service infrastructure. The system
keeps persistence local through SQLite and can run either directly from a Python virtual environment
or through Docker Compose.

At a high level:

- The backend is the source of truth for users, categories, products, stock, orders, payments,
  status transitions, and audit logs.
- The frontend is a Flutter customer app. It consumes the backend API for authentication, catalog
  data, order creation, order listing, order tracking refresh, and cancellation.
- Admin catalog and order management exists at the API level, but there is no admin Flutter UI yet.
- Visual features such as product images, ratings, promotions, delivery ETA, coupons, and route maps
  are local UI placeholders until matching backend contracts are created.

The project currently demonstrates a realistic separation between durable business behavior and
presentation-only polish. The backend protects business invariants; the Flutter app presents a
mobile customer experience inspired by modern food-ordering apps.

## 2. Repository Layout

The repository root contains shared documentation, Docker Compose, and the two application
packages:

```text
pedidolocal/
  backend/
    app/
      api/
      core/
      db/
      models/
      schemas/
      services/
    migrations/
    tests/
    Dockerfile
    docker-entrypoint.sh
    pyproject.toml
    alembic.ini
  frontend/
    android/
    lib/
      core/
      models/
      providers/
      repositories/
      screens/
      widgets/
    test/
    pubspec.yaml
  docker-compose.yml
  README.md
  ARCHITECTURE.md
  AGENTS.md
  PRESENTATION.md
```

### Root Files

- `README.md` gives quick-start commands for backend, Docker, frontend, and validation.
- `ARCHITECTURE.md` describes the system boundaries and integrity rules.
- `AGENTS.md` contains collaboration and verification rules for work on the repository.
- `docker-compose.yml` runs the backend container and persists the SQLite database in a named Docker
  volume.
- `.gitignore` excludes local environments, generated artifacts, local databases, Flutter build
  output, Gradle caches, logs, and local documentation artifacts.

### Backend Directory

The backend is a FastAPI application. It owns all durable domain behavior:

- Authentication and JWT token generation.
- Customer registration.
- Admin creation through a CLI command.
- Category CRUD through admin-only API endpoints.
- Product CRUD through admin-only API endpoints.
- Public category and product reads.
- Customer order creation.
- Order listing and order detail access.
- Order cancellation.
- Admin order status and payment status updates.
- Audit logging for important business actions.

### Frontend Directory

The frontend is a Flutter mobile app focused on the customer journey:

- Splash/onboarding screen.
- Login and registration.
- Home catalog with search and categories.
- Product detail and quantity selection.
- Cart and checkout.
- Order list.
- Static order tracking screen.
- Profile/logout.

It is not currently an admin panel. An admin can authenticate against the backend API, but the
Flutter app does not expose category/product/order administration screens.

## 3. Technology Stack

### Backend Stack

- Python 3.13
- FastAPI
- Pydantic v2
- SQLAlchemy 2.0
- Alembic
- SQLite
- PyJWT
- `pwdlib[argon2]`
- pytest
- Ruff
- Docker and Docker Compose

### Frontend Stack

- Flutter
- Dart
- Provider for state management
- `http` for API calls
- `flutter_secure_storage` for token storage
- `intl` for currency formatting
- Flutter widget and unit tests
- Android Gradle project generated under `frontend/android`

### Local Development Tools

The project has been tested locally with:

- Flutter installed at `D:\Development\flutter`
- Android SDK installed at `D:\Android\Sdk`
- Docker Desktop or another Docker-compatible runtime
- PowerShell on Windows

The exact local paths are not required by the project, but the commands in this document use
Windows PowerShell examples because that is the current development environment.

## 4. Runtime Requirements

### Required for Backend

For direct local backend development:

- Python 3.13
- A Python virtual environment
- Packages installed from `backend/pyproject.toml`

For Docker backend development:

- Docker
- Docker Compose

Docker is the simpler runtime path because the compose file sets backend environment variables,
applies migrations on startup, runs Uvicorn, and persists SQLite in a Docker volume.

### Required for Frontend

For Flutter development:

- Flutter stable SDK
- Dart from the Flutter SDK
- Android SDK
- Android SDK platform-tools
- Android SDK command-line tools
- Android emulator or physical device
- Accepted Android SDK licenses

Useful Windows `Path` entries:

```text
D:\Development\flutter\bin
D:\Android\Sdk\platform-tools
```

If Flutter is not on `PATH`, commands can still be run by using the full executable path:

```powershell
D:\Development\flutter\bin\flutter.bat
```

## 5. Environment Variables and Configuration

### Backend Settings

Backend settings are declared in `backend/app/core/config.py` and can be supplied through a `.env`
file or process environment.

Relevant settings:

```text
DATABASE_URL
JWT_SECRET_KEY
JWT_ALGORITHM
ACCESS_TOKEN_EXPIRE_MINUTES
ALLOWED_CITY
ENVIRONMENT
MAX_REQUEST_BODY_BYTES
```

The example file is:

```text
backend/.env.example
```

Default local values:

```text
DATABASE_URL=sqlite:///./pedidolocal.db
JWT_SECRET_KEY=change-this-development-secret-key-before-running
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
ALLOWED_CITY=Pedido Local
ENVIRONMENT=development
```

For production or any non-private environment, `JWT_SECRET_KEY` must be changed. The current default
is intentionally a development placeholder.

### Docker Compose Settings

`docker-compose.yml` sets development runtime values for the backend container:

```yaml
DATABASE_URL: "sqlite:////app/data/pedidolocal.db"
JWT_SECRET_KEY: "change-this-development-secret-key-before-running"
JWT_ALGORITHM: "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES: "30"
ALLOWED_CITY: "Pedido Local"
ENVIRONMENT: "development"
```

SQLite is stored in the named volume:

```text
backend_data
```

Inside the container, the database path is:

```text
/app/data/pedidolocal.db
```

### Frontend API Base URL

The Flutter app reads the backend URL from a Dart define:

```text
API_BASE_URL
```

It is configured in `frontend/lib/core/constants.dart`:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
```

The default is `http://10.0.2.2:8000`, which is the usual Android emulator address for reaching a
server running on the host machine.

When running against the local Docker backend from an Android emulator:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## 6. Backend Entrypoints

### FastAPI Application

The main FastAPI application lives at:

```text
backend/app/main.py
```

The import path used by Uvicorn is:

```text
app.main:app
```

Direct local run command:

```powershell
cd backend
.\.venv\Scripts\python -m uvicorn app.main:app --reload
```

Docker run command:

```powershell
docker compose up --build
```

### Docker Entrypoint

The backend Docker entrypoint is:

```text
backend/docker-entrypoint.sh
```

It applies migrations before starting Uvicorn:

```sh
python -m alembic upgrade head
exec "$@"
```

The Dockerfile then starts:

```text
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### CLI Entrypoint

The backend includes a CLI command for creating an admin user:

```text
pedido-local create-admin
```

Local virtual environment example:

```powershell
cd backend
.\.venv\Scripts\pedido-local create-admin --email admin@example.com --password Admin12345 --full-name "Admin"
```

Docker example:

```powershell
docker compose exec backend pedido-local create-admin --email admin@example.com --password Admin12345 --full-name "Admin"
```

This is currently the supported way to bootstrap admin access.

### API Documentation

When the backend is running, OpenAPI docs are available at:

```text
http://127.0.0.1:8000/docs
```

This is currently the most convenient manual admin interface for category/product/order management.

## 7. Frontend Entrypoints

### Flutter App Entrypoint

The Flutter app starts at:

```text
frontend/lib/main.dart
```

The root widget is:

```dart
PedidoLocalApp
```

It wires:

- `ApiClient`
- `TokenStorage`
- `AuthRepository`
- `CatalogRepository`
- `OrderRepository`
- `AuthProvider`
- `CartProvider`
- `CatalogProvider`
- `OrderProvider`
- `MaterialApp`
- `RouteGenerator`

### Frontend Routes

Routes are declared in:

```text
frontend/lib/core/routes.dart
```

Current routes:

```text
/               SplashScreen
/login          LoginScreen
/register       RegisterScreen
/home           HomeScreen
/product        ProductDetailScreen
/cart           CartScreen
/orders         OrderListScreen
/orders/detail  OrderTrackingScreen
/profile        ProfileScreen
```

Product and order detail screens receive model objects through route arguments.

### Frontend API Layer

The frontend API client lives in:

```text
frontend/lib/core/api/api_client.dart
```

It handles:

- Base URL composition.
- JSON requests.
- Form-encoded auth token requests.
- Bearer token headers.
- Response decoding.
- Timeout behavior.
- Mapping backend errors into frontend exceptions.

Endpoint constants live in:

```text
frontend/lib/core/api/endpoints.dart
```

## 8. Backend API Surface

### Public Endpoints

Public catalog reads:

```text
GET /categories
GET /categories/{category_id}
GET /products
GET /products/{product_id}
```

Health check:

```text
GET /health
```

Customer registration and login:

```text
POST /auth/register
POST /auth/token
GET /auth/me
```

`GET /auth/me` requires authentication.

### Admin Catalog Endpoints

Admin-only category management:

```text
POST /categories
PATCH /categories/{category_id}
DELETE /categories/{category_id}
```

Admin-only product management:

```text
POST /products
PATCH /products/{product_id}
DELETE /products/{product_id}
```

Deletes are soft deletes. Records are marked inactive rather than physically removed.

### Order Endpoints

Authenticated customer/admin order access:

```text
POST /orders
GET /orders
GET /orders/{order_id}
POST /orders/{order_id}/cancel
```

Admin-only order management:

```text
PATCH /orders/{order_id}/status
PATCH /orders/{order_id}/payment
```

### Audit Endpoints

The backend includes audit routes under `app.api.routes.audit`. Audit logs are meant to preserve a
technical trail of important actions such as auth events, catalog changes, and order changes.

## 9. Data Model and Business Concepts

### Users

Users have:

- Email.
- Full name.
- Role.
- Active state.
- Optional customer profile.

Roles distinguish customer behavior from admin behavior.

### Customer Profiles

Customer profiles include:

- Phone.
- Address line.
- City.
- Optional birth date.

Birth date matters for alcoholic product validation.

### Categories

Categories organize products. A product must belong to an active category when it is created or
moved.

Categories support:

- Name.
- Description.
- Active/inactive state.

### Products

Products include:

- Category ID.
- Name.
- Description.
- Price.
- Stock.
- Active/inactive state.
- Alcoholic flag.

The backend currently does not support product image URLs or uploads.

### Orders

Orders include:

- Customer ID.
- Status.
- Payment method.
- Payment status.
- Delivery city.
- Delivery address.
- Subtotal.
- Stock restoration flag.
- Creation/update timestamps.
- Cancellation/delivery timestamps.
- Order items.

Order items snapshot product name and unit price at the time of purchase. This is important because
the product name or price may change later, but existing order history should remain stable.

## 10. Customer App Flow

### 1. Splash

The app starts on the splash/onboarding screen. The user can press `Comecar agora` to enter the
customer experience.

### 2. Catalog Home

The home screen loads:

```text
GET /categories
GET /products
```

It displays:

- Location-style header.
- Search field.
- Promo banner.
- Category chips.
- Product grid.
- Bottom navigation.

Search and category filtering are performed locally in the app because backend filtering is not
currently part of the API contract.

### 3. Product Detail

When a user opens a product, the product detail screen shows:

- Local fallback visual.
- Product name.
- Placeholder rating.
- Description.
- Stock state.
- Alcoholic product notice if applicable.
- Quantity selector.
- Computed total.
- Add-to-cart action.

Adding to cart is local frontend state. No backend order exists until checkout.

### 4. Cart and Checkout

The cart screen shows:

- Cart line items.
- Quantity controls.
- Subtotal/order summary.
- Delivery address field.
- Delivery city field.
- Payment method selector.
- Submit button.

If the user is not authenticated, checkout redirects to login before creating the order.

Order creation calls:

```text
POST /orders
```

The backend then:

- Validates the customer.
- Validates delivery city.
- Validates product availability.
- Validates stock.
- Validates alcohol rules.
- Decrements stock.
- Creates order item snapshots.
- Stores the order.
- Writes audit logs.

### 5. Order Tracking

After checkout, the app opens order tracking. The screen shows:

- Static map-like local visual.
- Status timeline.
- Order summary.
- Payment information.
- Refresh action.
- Cancel action when the backend allows it.

Refresh calls:

```text
GET /orders/{order_id}
```

Cancel calls:

```text
POST /orders/{order_id}/cancel
```

### 6. Orders List

The orders screen loads:

```text
GET /orders
```

For customers, the backend returns their orders. Admin order access is supported by the backend but
not exposed in the Flutter UI.

### 7. Profile

The profile screen shows current user information and logout behavior. Logout clears the locally
stored JWT.

## 11. Admin Flow

There is no admin frontend yet.

The current admin flow is:

1. Create an admin user through the backend CLI.
2. Authenticate through `/auth/token`.
3. Use the returned bearer token.
4. Manage categories and products through the API or Swagger UI.
5. Manage order/payment status through the API or Swagger UI.

Example using Docker:

```powershell
docker compose exec backend pedido-local create-admin --email admin@example.com --password Admin12345 --full-name "Admin"
```

Then use:

```text
http://127.0.0.1:8000/docs
```

In Swagger UI:

1. Call `POST /auth/token`.
2. Copy the returned `access_token`.
3. Click `Authorize`.
4. Enter `Bearer <token>`.
5. Use admin endpoints such as `POST /categories` and `POST /products`.

This is functional but not friendly. A real admin UI is one of the clearest next steps.

## 12. How to Run the Project

### Option A: Backend with Docker Compose

From the repository root:

```powershell
docker compose up --build
```

Backend URL:

```text
http://127.0.0.1:8000
```

Health check:

```powershell
Invoke-RestMethod http://127.0.0.1:8000/health
```

Swagger:

```text
http://127.0.0.1:8000/docs
```

### Option B: Backend Directly from Python

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\python -m pip install --upgrade pip
.\.venv\Scripts\python -m pip install -e ".[dev]"
.\.venv\Scripts\python -m alembic upgrade head
.\.venv\Scripts\python -m uvicorn app.main:app --reload
```

Create an admin:

```powershell
.\.venv\Scripts\pedido-local create-admin --email admin@example.com --password Admin12345 --full-name "Admin"
```

### Frontend on Android Emulator

From the frontend directory:

```powershell
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

If Flutter is not on `PATH`:

```powershell
D:\Development\flutter\bin\flutter.bat run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Target a specific emulator:

```powershell
D:\Development\flutter\bin\flutter.bat devices
D:\Development\flutter\bin\flutter.bat run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## 13. Validation Commands

### Backend

From `backend`:

```powershell
.\.venv\Scripts\python -m pytest --cov=app --cov-report=term-missing
.\.venv\Scripts\python -m ruff check .
.\.venv\Scripts\python -m alembic upgrade head
```

The backend test suite runs against real migrated SQLite databases. This matters because a large
part of the backend behavior is transactional: stock decrement, stock restoration, unique product
constraints, order creation, and audit logs all depend on database behavior.

### Frontend

From `frontend`:

```powershell
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

The frontend tests cover:

- API client request behavior and error mapping.
- Model JSON parsing.
- Auth token persistence and logout.
- Cart totals and quantity behavior.
- Repository payloads.
- Home catalog success/error states.
- Product detail quantity behavior.
- Checkout submission.
- Order tracking display.

### Android Build Check

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## 14. Security and Integrity Design

The backend includes several protections that keep the MVP from becoming a toy API:

- Request body size is capped before endpoint processing.
- JWTs are signed and validated.
- Passwords are hashed with Argon2.
- Customer and admin endpoints are separated by dependencies.
- Inactive users cannot act.
- Admin-only endpoints require an active admin JWT.
- Input strings are trimmed and validated.
- Unsafe blank text is rejected.
- Product and category IDs have upper bounds.
- Money values have decimal constraints.
- Stock values are bounded.
- Duplicate products are not allowed inside the same order payload.
- Product stock is decremented transactionally during order creation.
- Product name and unit price are snapshotted into order items.
- Canceling a non-delivered order restores stock once.
- Invalid order status transitions are rejected.
- Alcoholic products require a customer birth date proving the customer is at least 18.
- Passwords, password hashes, and JWTs are not returned to clients or written into audit logs.

These rules make the backend much more important than the current frontend. The frontend is allowed
to be pleasant and convenient, but the backend must remain the source of truth.

## 15. Current Limitations

### No Admin UI

The largest functional gap is the absence of an admin frontend. Admins can create categories,
create products, update stock, deactivate products, and update orders through API endpoints, but
there is no Flutter screen for that yet.

In practical terms, product management currently happens through:

- Swagger UI at `/docs`.
- PowerShell/HTTP calls.
- Another API client.

### No Product Images

The backend has no product image field and no upload/storage flow. The Flutter app uses local
placeholder visuals and category-inspired icons.

Adding images properly would require decisions about:

- File uploads versus external URLs.
- Storage location.
- Image validation.
- Image resizing.
- CDN/object storage if the project leaves local-only mode.
- Frontend caching.

### No Real Payment Provider

Payment is represented as internal fields:

- `payment_method`
- `payment_status`

The system does not charge cards, process Pix, reconcile cash, or integrate with any payment API.

### No Live Delivery Tracking

The tracking screen uses a static map-like visual and backend order status. There is no live driver
location, map SDK, route calculation, ETA service, or geocoding.

### No Push Notifications

Customers must refresh or reopen order tracking to see updated status. There are no push
notifications or realtime WebSocket updates.

### Local-First SQLite Persistence

SQLite is excellent for this MVP, but it is not a full multi-tenant production deployment plan.
If the project grows, likely future work includes PostgreSQL, stronger backup/restore operations,
and stricter deployment secrets.

### City Constraint

Orders are restricted to one configured city through `ALLOWED_CITY`. This keeps the MVP simple but
means multi-city delivery is not implemented yet.

### Catalog Filtering Is Local

The app fetches categories and products, then applies search/category filtering locally. This is
fine for a small catalog, but a large catalog would need backend filtering, pagination, and indexes.

### No Offline Mode

The Flutter app does not currently cache catalog data for offline operation. It needs the backend
for auth, catalog loading, checkout, order listing, and tracking refresh.

## 16. Implementation Struggles and Notes

### Flutter Installation and Android SDK Setup

Flutter was originally installed at `C:\flutter`, then moved to `D:\Development\flutter`. After the
move, the Flutter package configuration inside the project became stale. This caused confusing
compiler errors where imports such as `package:flutter/material.dart` appeared to be missing even
though the source code was correct.

The fix was to regenerate Flutter project metadata:

```powershell
flutter clean
flutter pub get
```

Android SDK setup also needed cleanup. The SDK had enough installed to build part of the project,
but command-line tools and license acceptance were missing. That created a situation where Gradle
could build slowly or partially, while Flutter Doctor still reported Android toolchain issues.

The fix was:

- Install Android SDK command-line tools under `D:\Android\Sdk\cmdline-tools\latest`.
- Accept SDK licenses.
- Verify `adb` sees the emulator.
- Verify `flutter doctor -v`.

This is a classic Android setup trap: enough pieces exist to make progress, but not enough exist to
make the toolchain boring. Boring is the goal.

### Slow First Android Build

The first Android build installed missing pieces such as NDK/CMake and warmed Gradle caches. This
made `flutter run` appear frozen at points like:

```text
Running Gradle task 'assembleDebug'...
Installing build\app\outputs\flutter-apk\app-debug.apk...
```

Once dependencies were installed and caches warmed, debug APK build/install succeeded.

### Docker and SQLite

The Docker runtime needed to preserve SQLite data without running the container as root. The chosen
design:

- Creates a non-root `appuser`.
- Stores SQLite under `/app/data`.
- Mounts `/app/data` as a named Docker volume.
- Applies Alembic migrations on startup.

This keeps local Docker usage simple while avoiding a sloppy root container.

### Frontend Scope Control

The frontend screenshots suggested features that the backend does not support yet: images, ratings,
promotions, coupons, delivery ETA, and route maps. Instead of faking these as durable business data,
the app keeps them as presentation placeholders.

That choice matters. Fake persisted features are expensive later because users and code start
treating them as real. Presentation placeholders are honest: they make the UI feel closer to the
target product without lying about backend capability.

### Documentation Churn

Some planning docs were useful during implementation but were later marked as local/generated and
ignored:

- `AUDIT.md`
- `DOCS.html`
- `frontend/DOCUMENTATION.md`

The durable project documentation should live in tracked files such as:

- `README.md`
- `ARCHITECTURE.md`
- `AGENTS.md`
- `PRESENTATION.md`

## 17. Recommended Next Steps

### 1. Build an Admin UI

The next major product step is an admin interface. It should include:

- Admin login detection.
- Category list/create/edit/deactivate.
- Product list/create/edit/deactivate.
- Stock editing.
- Alcoholic product flag.
- Price editing.
- Order list for admins.
- Order status transitions.
- Payment status transitions.

This would remove the need to use Swagger or manual API calls for product management.

### 2. Add Product Images Properly

Add backend fields and storage strategy for product images. For a local-first MVP, this could start
with image URLs or local uploads, but the architecture should be explicit before implementation.

### 3. Add Backend Catalog Filtering

Add query parameters to `GET /products`, such as:

```text
category_id
search
active_only
limit
offset
```

Then the Flutter home screen can scale past tiny local catalogs.

### 4. Improve Tracking

Tracking could evolve from static display into:

- Status history.
- ETA.
- Delivery person assignment.
- Optional map coordinates.
- Customer-facing status messages.

### 5. Strengthen Production Configuration

Before any production-like deployment:

- Replace the development JWT secret.
- Decide on database backup strategy.
- Consider PostgreSQL.
- Add deployment-specific environment files or secrets.
- Add CORS rules if web clients are introduced.
- Add rate limiting for auth endpoints.

## 18. Quick Demo Script

This is a simple way to demonstrate the system locally.

### Start Backend

```powershell
docker compose up --build
```

### Create Admin

```powershell
docker compose exec backend pedido-local create-admin --email admin@example.com --password Admin12345 --full-name "Admin"
```

### Add Catalog Data

Open:

```text
http://127.0.0.1:8000/docs
```

Use `/auth/token` to get an admin token, authorize with `Bearer <token>`, then create:

- A category through `POST /categories`.
- One or more products through `POST /products`.

### Run Flutter App

```powershell
cd frontend
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### Customer Flow

1. Open the app.
2. Tap `Comecar agora`.
3. Register a customer.
4. Browse products.
5. Open product detail.
6. Add quantity to cart.
7. Checkout.
8. View tracking.
9. Refresh or cancel order if eligible.

## 19. Final Project State

Pedido Local is currently a solid local-first MVP foundation. The backend is more complete than the
frontend from an administration perspective: it already enforces core business rules and exposes
admin endpoints. The Flutter app gives customers a usable ordering flow but intentionally does not
pretend to be a full business operations dashboard.

The most important architectural principle is that durable truth lives in the backend. The frontend
can be improved, redesigned, or expanded, but stock, orders, user roles, permissions, and status
transitions must remain backend-owned.

That separation is what makes the project maintainable. The app can become prettier, the admin flow
can become more convenient, and the deployment can become more serious without having to untangle
business logic from UI-only code.
