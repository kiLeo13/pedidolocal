# Pedido Local

Local-first product ordering and delivery system. The repository is a monorepo with:

- `backend`: FastAPI REST API with SQLite, SQLAlchemy, Alembic, JWT auth, and pytest.
- `frontend`: Flutter mobile customer app. The frontend implementation plan lives in
  `frontend/DOCUMENTATION.md`.

## Backend Quick Start

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\python -m pip install --upgrade pip
.\.venv\Scripts\python -m pip install -e ".[dev]"
.\.venv\Scripts\python -m alembic upgrade head
.\.venv\Scripts\pedido-local create-admin --email admin@example.com --password Admin12345 --full-name "Admin"
.\.venv\Scripts\python -m uvicorn app.main:app --reload
```

API docs are available at `http://127.0.0.1:8000/docs` when the server is running.
Full project documentation in Portuguese is available at `DOCS.html`.

## Docker Backend Quick Start

Docker Compose runs the backend as a non-root container user, persists SQLite in a named
volume, applies Alembic migrations on startup, and exposes the API on port `8000`.

```powershell
docker compose up --build
```

Health check:

```powershell
Invoke-RestMethod http://127.0.0.1:8000/health
```

## Frontend Quick Start

Flutter is required on `PATH` for frontend commands.

```powershell
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For the Android emulator, `10.0.2.2` points back to the host machine where Docker exposes the
backend on port `8000`. For a physical phone on the same network, replace it with the host
machine's LAN IP, for example `http://192.168.1.50:8000`.

In development, the registration screen can create either customer or admin accounts. Admin users
can open `Perfil > Cadastrar produto` to create categories and products through the backend API.

## Validation

Backend:

```powershell
cd backend
.\.venv\Scripts\python -m pytest --cov=app --cov-report=term-missing
.\.venv\Scripts\python -m ruff check .
.\.venv\Scripts\python -m alembic upgrade head
```

Frontend, once Flutter is available:

```powershell
cd frontend
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```
