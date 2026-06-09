from typing import Any

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import AuditLog, User

SENSITIVE_KEYS = {"password", "hashed_password", "access_token", "token", "jwt"}


def sanitize_snapshot(value: dict[str, Any] | None) -> dict[str, Any] | None:
    if value is None:
        return None
    safe: dict[str, Any] = {}
    for key, item in value.items():
        if key.lower() in SENSITIVE_KEYS:
            continue
        safe[key] = item
    return safe


def add_audit_log(
    db: Session,
    *,
    actor: User | None,
    action: str,
    entity_type: str,
    entity_id: int | str | None,
    request_id: str,
    before: dict[str, Any] | None = None,
    after: dict[str, Any] | None = None,
    metadata: dict[str, Any] | None = None,
) -> AuditLog:
    log = AuditLog(
        actor_user_id=actor.id if actor else None,
        action=action,
        entity_type=entity_type,
        entity_id=str(entity_id) if entity_id is not None else None,
        request_id=request_id,
        before=sanitize_snapshot(before),
        after=sanitize_snapshot(after),
        log_metadata=sanitize_snapshot(metadata),
    )
    db.add(log)
    return log


def list_audit_logs(db: Session, *, limit: int = 100) -> list[AuditLog]:
    stmt = select(AuditLog).order_by(AuditLog.created_at.desc()).limit(limit)
    return list(db.scalars(stmt))
