# Pedido Local Technical Audit

## Requirement-To-Test Matrix

| Requirement | Evidence |
| --- | --- |
| Customer registration and JWT login | Auth functional tests |
| Admin-only catalog mutations | Catalog authorization tests |
| Public catalog reads | Catalog functional tests |
| Valid order creation | Order total, stock, and snapshot tests |
| Operation integrity | Transaction rollback and invalid transition tests |
| City-only delivery | City validation tests |
| Alcohol restriction | Age validation tests |
| Response consistency | Secret exclusion and status-code tests |
| Endpoint validation limits | Validation functional tests |
| Audit trail | Audit log creation and admin read tests |
| Persistence validation | Alembic-migrated SQLite test database |

## Audit Controls

- Authentication uses signed JWTs with expiration.
- Passwords are stored only as Argon2 hashes.
- Role checks gate privileged operations.
- Pydantic schemas reject invalid payloads before service logic runs.
- Request body size, text shape, price, stock, quantity, phone, and birth-date limits reduce abuse and manipulation surface.
- SQLAlchemy parameter binding is used for all persistence operations.
- Service-layer transactions keep stock and order writes consistent.
- Audit logs capture critical mutations with actor, action, entity, request id, and safe snapshots.

## Known Non-Goals

- No external payment processing.
- No courier routing.
- No frontend.
- No remote infrastructure.
