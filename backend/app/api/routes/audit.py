from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_admin
from app.db.session import get_db
from app.models import User
from app.schemas.audit import AuditLogResponse
from app.services.audit import list_audit_logs

router = APIRouter(prefix="/audit-logs", tags=["audit"])


@router.get("", response_model=list[AuditLogResponse])
def read_audit_logs(
    db: Annotated[Session, Depends(get_db)],
    _current_admin: Annotated[User, Depends(get_current_admin)],
    limit: int = Query(default=100, ge=1, le=500),
):
    return list_audit_logs(db, limit=limit)
