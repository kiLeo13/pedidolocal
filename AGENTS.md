# AGENTS.md

## Project Rules

- Monorepo with a FastAPI backend in `/backend` and a Flutter mobile frontend in `/frontend`.
- Backend uses FastAPI, Pydantic v2, SQLAlchemy 2.0, Alembic, SQLite, JWT, and pytest.
- Frontend uses Flutter and must stay isolated in `/frontend`; do not add UI code to `/backend`.
- Keep persistence local; no external cloud services are part of this stage.
- Use small, reviewable diffs and keep behavior changes covered by tests.
- Update architecture or feature documentation whenever backend or frontend behavior changes.
- Do not run git commands that affect remotes.
- Do not open Android Studio, desktop mode, or other IDE/device tools unless explicitly requested.

## Verification

Before considering a backend task complete, run from the `backend` directory:

```powershell
cd backend
.\.venv\Scripts\python -m pytest --cov=app --cov-report=term-missing
.\.venv\Scripts\python -m ruff check .
.\.venv\Scripts\python -m alembic upgrade head
```

Before considering a frontend task complete, run from the `frontend` directory when Flutter is
available on `PATH`:

```powershell
cd frontend
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Frontend implementation planning lives in `frontend/DOCUMENTATION.md`.
