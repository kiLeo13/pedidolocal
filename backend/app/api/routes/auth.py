from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_request_id
from app.core.security import create_access_token
from app.db.session import get_db
from app.models import User
from app.schemas.auth import CustomerRegisterRequest, TokenResponse
from app.schemas.users import UserResponse
from app.services import auth as auth_service

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register_customer(
    payload: CustomerRegisterRequest,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
) -> User:
    return auth_service.register_customer(db, payload, request_id=get_request_id(request))


@router.post("/token", response_model=TokenResponse)
def login_for_access_token(
    request: Request,
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    db: Annotated[Session, Depends(get_db)],
) -> TokenResponse:
    user = auth_service.authenticate_user(
        db,
        email=form_data.username,
        password=form_data.password,
        request_id=get_request_id(request),
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    token = create_access_token(subject=str(user.id), role=user.role.value)
    return TokenResponse(access_token=token)


@router.get("/me", response_model=UserResponse)
def read_current_user(current_user: Annotated[User, Depends(get_current_user)]) -> User:
    return current_user
