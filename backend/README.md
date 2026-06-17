# Pedido Local Backend

FastAPI REST API for Pedido Local.

This file exists inside `/backend` so the Python package metadata declared in
`pyproject.toml` can be built from the backend directory, including during Docker image builds.

## Docker

From the repository root:

```powershell
docker compose up --build
```

The container runs as a non-root `appuser`, applies `alembic upgrade head` before starting
Uvicorn, and stores SQLite data in the `backend_data` Docker volume at
`/app/data/pedidolocal.db`.

## CORS

The API currently uses a fully permissive CORS policy for development: all origins, methods,
request headers, exposed headers, credentials, and browser `OPTIONS` preflight requests are
allowed. Tighten this to a trusted-origin allowlist before deploying outside local development.

## Development Admin Access

`POST /auth/register` accepts `role=admin` only while `ENVIRONMENT=development`. This is meant to
speed up local testing of admin screens. In any other environment, admin self-registration returns
`403` and admins should be created through controlled operational tooling such as:

```powershell
.\.venv\Scripts\pedido-local create-admin --email admin@example.com --password Admin12345 --full-name "Admin"
```
