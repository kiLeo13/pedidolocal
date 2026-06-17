# Pedido Local Architecture

## Purpose

Pedido Local is a local-first ordering system for selling and delivering products inside one configured city. The repository is organized as a monorepo with a FastAPI backend and a Flutter mobile frontend. The MVP supports customer registration, JWT login, public catalog reads, admin catalog management, customer order creation/cancellation, admin order/payment status management, and technical audit logs.

## Stack

### Backend

- FastAPI exposes the REST API and OpenAPI documentation.
- Pydantic v2 validates request and response contracts.
- SQLAlchemy 2.0 maps domain models to SQLite.
- Alembic owns database schema migrations.
- PyJWT signs access tokens.
- `pwdlib[argon2]` hashes passwords.
- pytest validates functional behavior against real migrated SQLite databases.

### Frontend

- Flutter provides the mobile customer application in `/frontend`.
- The frontend consumes the backend REST API for authentication, catalog reads, and orders.
- Screenshot-inspired presentation details that do not exist in the backend contract yet remain local UI placeholders.

## Boundaries

The backend remains an intentionally monolithic API. There are no cloud dependencies, message brokers, external payment providers, push notifications, or live map services in this stage. Payment data is recorded as internal method/status fields only.

The Flutter app is a separate frontend package inside the same repository. It must not introduce backend persistence, hidden business rules, or fake durable data. Product images, ratings, promotions, coupons, delivery ETA, and map route details are local presentation placeholders until backend contracts exist.

## Integrity Rules

- Request bodies are capped by `MAX_REQUEST_BODY_BYTES` before endpoint validation.
- Incoming text is trimmed, bounded by Pydantic field limits, and rejected when blank or unsafe.
- Money, stock, IDs, phone numbers, birth dates, and order item quantities have explicit limits.
- Orders can only be delivered inside the configured `ALLOWED_CITY`.
- Order items store product name and unit price snapshots at creation time.
- Stock is decremented in the same transaction that creates an order.
- Stock is restored once when a non-delivered order is canceled.
- Alcoholic products require a customer birth date proving age of at least 18 years.
- Admin-only endpoints require a JWT for an active admin user.
- Status transitions are explicit and invalid transitions are rejected.
- Passwords, password hashes, and JWTs are never returned or written to audit logs.

## Data Flow

Requests enter through `app.api.routes`, which depend on authenticated users and database sessions from `app.api.deps`. Business rules live in `app.services`. ORM models live in `app.models`, and Pydantic API contracts live in `app.schemas`. Alembic migrations define the persisted SQLite schema.

The Flutter app calls the REST API through a configurable base URL. For Android emulator development against a Dockerized backend, the default frontend API URL should be `http://10.0.2.2:8000`. Authenticated frontend flows store JWTs locally and send them as bearer tokens for protected order and profile endpoints.

## Runtime

The backend can run locally from a virtual environment or through Docker Compose. The Docker
runtime builds from `/backend`, runs as a non-root `appuser`, applies Alembic migrations on
startup, stores SQLite data in the `backend_data` volume at `/app/data/pedidolocal.db`, and
serves the API on port `8000`.

## CORS

The backend currently installs FastAPI/Starlette CORS middleware in a deliberately permissive
development configuration. It allows any origin, any method, any request header, exposes all
response headers, allows credentials, and handles browser `OPTIONS` preflight requests before route
authentication. This is useful for local mobile/web experimentation across emulators, host
machines, and temporary frontend origins.

Before any production deployment, replace this permissive policy with an explicit allowlist of
trusted frontend origins.

## Frontend Plan

The implementation plan for the Flutter customer app lives in `frontend/DOCUMENTATION.md`. Keep that document updated as frontend milestones, API assumptions, or validation steps change.
