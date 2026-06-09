from typing import Annotated

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.security import decode_access_token
from app.db.session import get_db
from app.models import Role, User
from app.services.audit import add_audit_log
from app.services.auth import get_user_by_id

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/token", auto_error=False)


def get_request_id(request: Request) -> str:
    return str(getattr(request.state, "request_id", "missing-request-id"))


def get_current_user(
    request: Request,
    token: Annotated[str | None, Depends(oauth2_scheme)],
    db: Annotated[Session, Depends(get_db)],
) -> User:
    request_id = get_request_id(request)
    if not token:
        add_audit_log(
            db,
            actor=None,
            action="auth.missing_token",
            entity_type="auth",
            entity_id=None,
            request_id=request_id,
        )
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="not authenticated",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_access_token(token)
        user_id = int(payload["sub"])
    except (KeyError, TypeError, ValueError):
        add_audit_log(
            db,
            actor=None,
            action="auth.invalid_token",
            entity_type="auth",
            entity_id=None,
            request_id=request_id,
        )
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        ) from None

    user = get_user_by_id(db, user_id)
    if not user or not user.is_active:
        add_audit_log(
            db,
            actor=user if user else None,
            action="auth.inactive_or_missing_user",
            entity_type="user",
            entity_id=user_id,
            request_id=request_id,
        )
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


def get_current_admin(
    request: Request,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[Session, Depends(get_db)],
) -> User:
    if current_user.role != Role.ADMIN:
        add_audit_log(
            db,
            actor=current_user,
            action="authorization.denied",
            entity_type="user",
            entity_id=current_user.id,
            request_id=get_request_id(request),
            metadata={"required_role": Role.ADMIN.value, "actual_role": current_user.role.value},
        )
        db.commit()
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="admin role required")
    return current_user
