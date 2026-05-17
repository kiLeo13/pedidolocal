from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.exceptions import DomainError
from app.core.security import DUMMY_HASH, get_password_hash, verify_password
from app.models import CustomerProfile, Role, User
from app.schemas.auth import CustomerRegisterRequest
from app.services.audit import add_audit_log


def normalize_email(email: str) -> str:
    return email.strip().lower()


def get_user_by_email(db: Session, email: str) -> User | None:
    stmt = select(User).where(User.email == normalize_email(email))
    return db.scalar(stmt)


def get_user_by_id(db: Session, user_id: int) -> User | None:
    return db.get(User, user_id)


def register_customer(
    db: Session,
    payload: CustomerRegisterRequest,
    *,
    request_id: str,
) -> User:
    email = normalize_email(str(payload.email))
    if get_user_by_email(db, email):
        add_audit_log(
            db,
            actor=None,
            action="auth.register_failed",
            entity_type="user",
            entity_id=None,
            request_id=request_id,
            metadata={"email": email, "reason": "duplicate_email"},
        )
        db.commit()
        raise DomainError("email is already registered", status_code=409)

    user = User(
        email=email,
        full_name=payload.full_name,
        hashed_password=get_password_hash(payload.password),
        role=Role.CUSTOMER,
    )
    user.profile = CustomerProfile(
        phone=payload.phone,
        address_line=payload.address_line,
        city=payload.city,
        birth_date=payload.birth_date,
    )
    db.add(user)
    try:
        db.flush()
    except IntegrityError as exc:
        db.rollback()
        raise DomainError("email is already registered", status_code=409) from exc

    add_audit_log(
        db,
        actor=user,
        action="auth.registered",
        entity_type="user",
        entity_id=user.id,
        request_id=request_id,
        after={"email": user.email, "role": user.role.value},
    )
    db.commit()
    db.refresh(user)
    return user


def authenticate_user(
    db: Session,
    *,
    email: str,
    password: str,
    request_id: str,
) -> User | None:
    normalized_email = normalize_email(email)
    user = get_user_by_email(db, normalized_email)
    hashed_password = user.hashed_password if user else DUMMY_HASH
    password_ok = verify_password(password, hashed_password)

    if not user or not password_ok or not user.is_active:
        add_audit_log(
            db,
            actor=user if user else None,
            action="auth.login_failed",
            entity_type="user",
            entity_id=user.id if user else None,
            request_id=request_id,
            metadata={"email": normalized_email, "reason": "invalid_credentials"},
        )
        db.commit()
        return None

    add_audit_log(
        db,
        actor=user,
        action="auth.login_success",
        entity_type="user",
        entity_id=user.id,
        request_id=request_id,
        metadata={"email": normalized_email},
    )
    db.commit()
    db.refresh(user)
    return user


def create_admin_user(db: Session, *, email: str, password: str, full_name: str) -> User:
    normalized_email = normalize_email(email)
    existing = get_user_by_email(db, normalized_email)
    if existing:
        if existing.role != Role.ADMIN:
            raise DomainError("email is already registered as a non-admin user", status_code=409)
        return existing

    user = User(
        email=normalized_email,
        full_name=full_name,
        hashed_password=get_password_hash(password),
        role=Role.ADMIN,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user
