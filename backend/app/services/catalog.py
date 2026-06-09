from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.exceptions import DomainError
from app.models import Category, Product, User
from app.schemas.catalog import CategoryCreate, CategoryUpdate, ProductCreate, ProductUpdate
from app.services.audit import add_audit_log


def list_categories(db: Session, *, active_only: bool = True) -> list[Category]:
    stmt = select(Category).order_by(Category.name)
    if active_only:
        stmt = stmt.where(Category.is_active.is_(True))
    return list(db.scalars(stmt))


def get_category(db: Session, category_id: int, *, active_only: bool = True) -> Category:
    category = db.get(Category, category_id)
    if not category or (active_only and not category.is_active):
        raise DomainError("category not found", status_code=404)
    return category


def create_category(
    db: Session,
    payload: CategoryCreate,
    *,
    actor: User,
    request_id: str,
) -> Category:
    category = Category(name=payload.name, description=payload.description)
    db.add(category)
    try:
        db.flush()
    except IntegrityError as exc:
        db.rollback()
        raise DomainError("category name already exists", status_code=409) from exc

    add_audit_log(
        db,
        actor=actor,
        action="category.created",
        entity_type="category",
        entity_id=category.id,
        request_id=request_id,
        after={"name": category.name, "is_active": category.is_active},
    )
    db.commit()
    db.refresh(category)
    return category


def update_category(
    db: Session,
    category_id: int,
    payload: CategoryUpdate,
    *,
    actor: User,
    request_id: str,
) -> Category:
    category = get_category(db, category_id, active_only=False)
    before = {
        "name": category.name,
        "description": category.description,
        "is_active": category.is_active,
    }
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(category, field, value)
    try:
        db.flush()
    except IntegrityError as exc:
        db.rollback()
        raise DomainError("category name already exists", status_code=409) from exc

    add_audit_log(
        db,
        actor=actor,
        action="category.updated",
        entity_type="category",
        entity_id=category.id,
        request_id=request_id,
        before=before,
        after={
            "name": category.name,
            "description": category.description,
            "is_active": category.is_active,
        },
    )
    db.commit()
    db.refresh(category)
    return category


def soft_delete_category(
    db: Session,
    category_id: int,
    *,
    actor: User,
    request_id: str,
) -> Category:
    return update_category(
        db,
        category_id,
        CategoryUpdate(is_active=False),
        actor=actor,
        request_id=request_id,
    )


def list_products(db: Session, *, active_only: bool = True) -> list[Product]:
    stmt = select(Product).order_by(Product.name)
    if active_only:
        stmt = stmt.where(Product.is_active.is_(True))
    return list(db.scalars(stmt))


def get_product(db: Session, product_id: int, *, active_only: bool = True) -> Product:
    product = db.get(Product, product_id)
    if not product or (active_only and not product.is_active):
        raise DomainError("product not found", status_code=404)
    if active_only and not product.category.is_active:
        raise DomainError("product not found", status_code=404)
    return product


def create_product(
    db: Session,
    payload: ProductCreate,
    *,
    actor: User,
    request_id: str,
) -> Product:
    category = get_category(db, payload.category_id, active_only=True)
    product = Product(
        category_id=category.id,
        name=payload.name,
        description=payload.description,
        price=payload.price,
        stock=payload.stock,
        is_active=payload.is_active,
        is_alcoholic=payload.is_alcoholic,
    )
    db.add(product)
    db.flush()
    add_audit_log(
        db,
        actor=actor,
        action="product.created",
        entity_type="product",
        entity_id=product.id,
        request_id=request_id,
        after={
            "name": product.name,
            "price": str(product.price),
            "stock": product.stock,
            "is_active": product.is_active,
            "is_alcoholic": product.is_alcoholic,
        },
    )
    db.commit()
    db.refresh(product)
    return product


def update_product(
    db: Session,
    product_id: int,
    payload: ProductUpdate,
    *,
    actor: User,
    request_id: str,
) -> Product:
    product = get_product(db, product_id, active_only=False)
    before = {
        "category_id": product.category_id,
        "name": product.name,
        "price": str(product.price),
        "stock": product.stock,
        "is_active": product.is_active,
        "is_alcoholic": product.is_alcoholic,
    }
    updates = payload.model_dump(exclude_unset=True)
    if "category_id" in updates:
        get_category(db, updates["category_id"], active_only=True)
    for field, value in updates.items():
        setattr(product, field, value)

    add_audit_log(
        db,
        actor=actor,
        action="product.updated",
        entity_type="product",
        entity_id=product.id,
        request_id=request_id,
        before=before,
        after={
            "category_id": product.category_id,
            "name": product.name,
            "price": str(product.price),
            "stock": product.stock,
            "is_active": product.is_active,
            "is_alcoholic": product.is_alcoholic,
        },
    )
    db.commit()
    db.refresh(product)
    return product


def soft_delete_product(db: Session, product_id: int, *, actor: User, request_id: str) -> Product:
    return update_product(
        db,
        product_id,
        ProductUpdate(is_active=False),
        actor=actor,
        request_id=request_id,
    )
