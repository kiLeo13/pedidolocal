from typing import Annotated

from fastapi import APIRouter, Depends, Request, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_admin, get_request_id
from app.db.session import get_db
from app.models import User
from app.schemas.catalog import (
    CategoryCreate,
    CategoryResponse,
    CategoryUpdate,
    ProductCreate,
    ProductResponse,
    ProductUpdate,
)
from app.services import catalog as catalog_service

router = APIRouter(tags=["catalog"])


@router.get("/categories", response_model=list[CategoryResponse])
def list_categories(db: Annotated[Session, Depends(get_db)]):
    return catalog_service.list_categories(db)


@router.get("/categories/{category_id}", response_model=CategoryResponse)
def get_category(category_id: int, db: Annotated[Session, Depends(get_db)]):
    return catalog_service.get_category(db, category_id)


@router.post("/categories", response_model=CategoryResponse, status_code=status.HTTP_201_CREATED)
def create_category(
    payload: CategoryCreate,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
    current_admin: Annotated[User, Depends(get_current_admin)],
):
    return catalog_service.create_category(
        db,
        payload,
        actor=current_admin,
        request_id=get_request_id(request),
    )


@router.patch("/categories/{category_id}", response_model=CategoryResponse)
def update_category(
    category_id: int,
    payload: CategoryUpdate,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
    current_admin: Annotated[User, Depends(get_current_admin)],
):
    return catalog_service.update_category(
        db,
        category_id,
        payload,
        actor=current_admin,
        request_id=get_request_id(request),
    )


@router.delete("/categories/{category_id}", response_model=CategoryResponse)
def soft_delete_category(
    category_id: int,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
    current_admin: Annotated[User, Depends(get_current_admin)],
):
    return catalog_service.soft_delete_category(
        db,
        category_id,
        actor=current_admin,
        request_id=get_request_id(request),
    )


@router.get("/products", response_model=list[ProductResponse])
def list_products(db: Annotated[Session, Depends(get_db)]):
    return catalog_service.list_products(db)


@router.get("/products/{product_id}", response_model=ProductResponse)
def get_product(product_id: int, db: Annotated[Session, Depends(get_db)]):
    return catalog_service.get_product(db, product_id)


@router.post("/products", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(
    payload: ProductCreate,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
    current_admin: Annotated[User, Depends(get_current_admin)],
):
    return catalog_service.create_product(
        db,
        payload,
        actor=current_admin,
        request_id=get_request_id(request),
    )


@router.patch("/products/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: int,
    payload: ProductUpdate,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
    current_admin: Annotated[User, Depends(get_current_admin)],
):
    return catalog_service.update_product(
        db,
        product_id,
        payload,
        actor=current_admin,
        request_id=get_request_id(request),
    )


@router.delete("/products/{product_id}", response_model=ProductResponse)
def soft_delete_product(
    product_id: int,
    request: Request,
    db: Annotated[Session, Depends(get_db)],
    current_admin: Annotated[User, Depends(get_current_admin)],
):
    return catalog_service.soft_delete_product(
        db,
        product_id,
        actor=current_admin,
        request_id=get_request_id(request),
    )
