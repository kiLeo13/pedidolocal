# AGENTS.md

## Project Rules

- Backend-only Python monolith; do not add UI code.
- Use FastAPI, Pydantic v2, SQLAlchemy 2.0, Alembic, SQLite, JWT, and pytest.
- Keep persistence local; no external cloud services are part of this stage.
- Use small, reviewable diffs and keep behavior changes covered by tests.
- Update architecture or feature documentation whenever backend behavior changes.
- Do not run git commands that affect remotes.

## Verification

Before considering a task complete, run:

```powershell
.\.venv\Scripts\python -m pytest --cov=app --cov-report=term-missing
.\.venv\Scripts\python -m ruff check .
.\.venv\Scripts\python -m alembic upgrade head
```
