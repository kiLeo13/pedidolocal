# Pedido Local Backend

Python monolith REST API for a local-city product ordering and delivery service.

## Quick Start

```powershell
python -m venv .venv
.\.venv\Scripts\python -m pip install --upgrade pip
.\.venv\Scripts\python -m pip install -e ".[dev]"
.\.venv\Scripts\python -m alembic upgrade head
.\.venv\Scripts\pedido-local create-admin --email admin@example.com --password Admin12345 --full-name "Admin"
.\.venv\Scripts\python -m uvicorn app.main:app --reload
```

API docs are available at `http://127.0.0.1:8000/docs` when the server is running.
Full project documentation in Portuguese is available at `DOCS.html`.

## Validation

```powershell
.\.venv\Scripts\python -m pytest --cov=app --cov-report=term-missing
.\.venv\Scripts\python -m ruff check .
.\.venv\Scripts\python -m alembic upgrade head
```
