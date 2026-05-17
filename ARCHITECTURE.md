# Pedido Local Architecture

## Purpose

Pedido Local is a backend-only monolith for selling and delivering products inside one configured city. The MVP supports customer registration, JWT login, public catalog reads, admin catalog management, customer order creation/cancellation, admin order/payment status management, and technical audit logs.

## Stack

- FastAPI exposes the REST API and OpenAPI documentation.
- Pydantic v2 validates request and response contracts.
- SQLAlchemy 2.0 maps domain models to SQLite.
- Alembic owns database schema migrations.
- PyJWT signs access tokens.
- `pwdlib[argon2]` hashes passwords.
- pytest validates functional behavior against real migrated SQLite databases.

## Boundaries

The application is intentionally monolithic. There are no cloud dependencies, message brokers, external payment providers, or UI assets. Payment data is recorded as internal method/status fields only.

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
