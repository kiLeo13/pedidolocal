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
