from typing import Annotated

from fastapi import APIRouter, Depends, Request, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_admin, get_current_user, get_request_id
from app.db.session import get_db
from app.models import OrderStatus, User
from app.schemas.orders import (
    OrderCreate,
    OrderResponse,
    OrderStatusUpdate,
    PaymentStatusUpdate,
)
from app.services import orders as order_service

router = APIRouter(prefix="/orders", tags=["orders"])


@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(
    payload: OrderCreate,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    return order_service.create_order(
        db,
        payload,
        actor=current_user,
        request_id=get_request_id(request),
    )


@router.get("", response_model=list[OrderResponse])
def list_orders(
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    status: OrderStatus | None = None,
    customer_id: int | None = None,
):
    return order_service.list_orders(
        db,
        actor=current_user,
        status=status,
        customer_id=customer_id,
    )


@router.get("/{order_id}", response_model=OrderResponse)
def get_order(
    order_id: int,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    return order_service.get_order_for_actor(db, order_id, actor=current_user)


@router.post("/{order_id}/cancel", response_model=OrderResponse)
def cancel_order(
    order_id: int,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    return order_service.cancel_order(
        db,
        order_id,
        actor=current_user,
        request_id=get_request_id(request),
    )


@router.patch("/{order_id}/status", response_model=OrderResponse)
def update_order_status(
    order_id: int,
    payload: OrderStatusUpdate,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
    current_admin: Annotated[User, Depends(get_current_admin)],
):
    return order_service.update_order_status(
        db,
        order_id,
        new_status=payload.status,
        actor=current_admin,
        request_id=get_request_id(request),
    )


@router.patch("/{order_id}/payment", response_model=OrderResponse)
def update_payment_status(
    order_id: int,
    payload: PaymentStatusUpdate,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
    current_admin: Annotated[User, Depends(get_current_admin)],
):
    return order_service.update_payment_status(
        db,
        order_id,
        new_status=payload.payment_status,
        actor=current_admin,
        request_id=get_request_id(request),
    )
