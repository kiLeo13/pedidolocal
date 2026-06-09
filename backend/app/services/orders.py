from datetime import date
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.core.config import get_settings
from app.core.exceptions import DomainError
from app.models import Order, OrderItem, OrderStatus, PaymentStatus, Product, Role, User, utc_now
from app.schemas.orders import OrderCreate
from app.services.audit import add_audit_log

ORDER_TRANSITIONS: dict[OrderStatus, set[OrderStatus]] = {
    OrderStatus.PENDING: {OrderStatus.CONFIRMED, OrderStatus.CANCELED},
    OrderStatus.CONFIRMED: {OrderStatus.PREPARING, OrderStatus.CANCELED},
    OrderStatus.PREPARING: {OrderStatus.OUT_FOR_DELIVERY, OrderStatus.CANCELED},
    OrderStatus.OUT_FOR_DELIVERY: {OrderStatus.DELIVERED},
    OrderStatus.DELIVERED: set(),
    OrderStatus.CANCELED: set(),
}

PAYMENT_TRANSITIONS: dict[PaymentStatus, set[PaymentStatus]] = {
    PaymentStatus.PENDING: {PaymentStatus.PAID, PaymentStatus.FAILED},
    PaymentStatus.FAILED: {PaymentStatus.PENDING, PaymentStatus.PAID},
    PaymentStatus.PAID: {PaymentStatus.REFUNDED},
    PaymentStatus.REFUNDED: set(),
}


def user_is_adult(birth_date: date | None, *, today: date | None = None) -> bool:
    if birth_date is None:
        return False
    current = today or date.today()
    age = current.year - birth_date.year
    if (current.month, current.day) < (birth_date.month, birth_date.day):
        age -= 1
    return age >= 18


def ensure_allowed_city(city: str) -> None:
    allowed_city = get_settings().allowed_city
    if city.strip().casefold() != allowed_city.strip().casefold():
        raise DomainError(f"delivery is only available in {allowed_city}", status_code=400)


def reject_order_creation(
    db: Session,
    *,
    actor: User,
    request_id: str,
    reason: str,
    message: str,
    status_code: int,
) -> None:
    add_audit_log(
        db,
        actor=actor,
        action="order.create_rejected",
        entity_type="order",
        entity_id=None,
        request_id=request_id,
        metadata={"reason": reason},
    )
    db.commit()
    raise DomainError(message, status_code=status_code)


def list_orders(
    db: Session,
    *,
    actor: User,
    status: OrderStatus | None = None,
    customer_id: int | None = None,
) -> list[Order]:
    stmt = select(Order).options(selectinload(Order.items)).order_by(Order.created_at.desc())
    if actor.role == Role.CUSTOMER:
        stmt = stmt.where(Order.customer_id == actor.id)
    elif customer_id is not None:
        stmt = stmt.where(Order.customer_id == customer_id)
    if status is not None:
        stmt = stmt.where(Order.status == status)
    return list(db.scalars(stmt))


def get_order_for_actor(db: Session, order_id: int, *, actor: User) -> Order:
    stmt = select(Order).options(selectinload(Order.items)).where(Order.id == order_id)
    order = db.scalar(stmt)
    if not order:
        raise DomainError("order not found", status_code=404)
    if actor.role == Role.CUSTOMER and order.customer_id != actor.id:
        raise DomainError("order not found", status_code=404)
    return order


def create_order(db: Session, payload: OrderCreate, *, actor: User, request_id: str) -> Order:
    if actor.role != Role.CUSTOMER or not actor.profile:
        reject_order_creation(
            db,
            actor=actor,
            request_id=request_id,
            reason="customer_profile_required",
            message="only customers with profiles can create orders",
            status_code=403,
        )

    try:
        ensure_allowed_city(payload.delivery_city)
    except DomainError as exc:
        reject_order_creation(
            db,
            actor=actor,
            request_id=request_id,
            reason="city_not_allowed",
            message=exc.message,
            status_code=exc.status_code,
        )

    product_ids = [item.product_id for item in payload.items]
    stmt = select(Product).where(Product.id.in_(product_ids))
    products_by_id = {product.id: product for product in db.scalars(stmt)}

    for item in payload.items:
        product = products_by_id.get(item.product_id)
        if not product or not product.is_active or not product.category.is_active:
            reject_order_creation(
                db,
                actor=actor,
                request_id=request_id,
                reason="product_unavailable",
                message=f"product {item.product_id} is unavailable",
                status_code=404,
            )
        if product.stock < item.quantity:
            reject_order_creation(
                db,
                actor=actor,
                request_id=request_id,
                reason="insufficient_stock",
                message=f"insufficient stock for product {product.id}",
                status_code=409,
            )
        if product.is_alcoholic and not user_is_adult(actor.profile.birth_date):
            reject_order_creation(
                db,
                actor=actor,
                request_id=request_id,
                reason="age_restricted_product",
                message="customer must be at least 18 years old for alcoholic products",
                status_code=403,
            )

    order = Order(
        customer_id=actor.id,
        status=OrderStatus.PENDING,
        payment_method=payload.payment_method,
        payment_status=PaymentStatus.PENDING,
        delivery_city=payload.delivery_city,
        delivery_address=payload.delivery_address,
        subtotal=Decimal("0.00"),
    )
    subtotal = Decimal("0.00")
    for item in payload.items:
        product = products_by_id[item.product_id]
        product.stock -= item.quantity
        line_total = product.price * item.quantity
        subtotal += line_total
        order.items.append(
            OrderItem(
                product_id=product.id,
                product_name_snapshot=product.name,
                unit_price=product.price,
                quantity=item.quantity,
                line_total=line_total,
            )
        )
    order.subtotal = subtotal
    db.add(order)
    db.flush()
    add_audit_log(
        db,
        actor=actor,
        action="order.created",
        entity_type="order",
        entity_id=order.id,
        request_id=request_id,
        after={
            "customer_id": order.customer_id,
            "status": order.status.value,
            "subtotal": str(order.subtotal),
            "item_count": len(order.items),
        },
    )
    db.commit()
    db.refresh(order)
    return order


def restore_order_stock(order: Order) -> None:
    if order.stock_restored:
        return
    for item in order.items:
        item.product.stock += item.quantity
    order.stock_restored = True


def cancel_order(db: Session, order_id: int, *, actor: User, request_id: str) -> Order:
    order = get_order_for_actor(db, order_id, actor=actor)
    if order.status == OrderStatus.CANCELED:
        return order
    if order.status == OrderStatus.DELIVERED:
        raise DomainError("delivered orders cannot be canceled", status_code=409)
    before = {"status": order.status.value, "stock_restored": order.stock_restored}
    restore_order_stock(order)
    order.status = OrderStatus.CANCELED
    order.canceled_at = utc_now()
    add_audit_log(
        db,
        actor=actor,
        action="order.canceled",
        entity_type="order",
        entity_id=order.id,
        request_id=request_id,
        before=before,
        after={"status": order.status.value, "stock_restored": order.stock_restored},
    )
    db.commit()
    db.refresh(order)
    return order


def update_order_status(
    db: Session,
    order_id: int,
    *,
    new_status: OrderStatus,
    actor: User,
    request_id: str,
) -> Order:
    order = get_order_for_actor(db, order_id, actor=actor)
    if new_status == order.status:
        return order
    if new_status not in ORDER_TRANSITIONS[order.status]:
        raise DomainError(
            f"cannot change order status from {order.status.value} to {new_status.value}",
            status_code=409,
        )

    before = {
        "status": order.status.value,
        "stock_restored": order.stock_restored,
        "delivered_at": order.delivered_at.isoformat() if order.delivered_at else None,
    }
    if new_status == OrderStatus.CANCELED:
        restore_order_stock(order)
        order.canceled_at = utc_now()
    if new_status == OrderStatus.DELIVERED:
        order.delivered_at = utc_now()
    order.status = new_status
    add_audit_log(
        db,
        actor=actor,
        action="order.status_updated",
        entity_type="order",
        entity_id=order.id,
        request_id=request_id,
        before=before,
        after={
            "status": order.status.value,
            "stock_restored": order.stock_restored,
            "delivered_at": order.delivered_at.isoformat() if order.delivered_at else None,
        },
    )
    db.commit()
    db.refresh(order)
    return order


def update_payment_status(
    db: Session,
    order_id: int,
    *,
    new_status: PaymentStatus,
    actor: User,
    request_id: str,
) -> Order:
    order = get_order_for_actor(db, order_id, actor=actor)
    if new_status == order.payment_status:
        return order
    if new_status not in PAYMENT_TRANSITIONS[order.payment_status]:
        raise DomainError(
            f"cannot change payment status from {order.payment_status.value} to {new_status.value}",
            status_code=409,
        )
    before = {"payment_status": order.payment_status.value}
    order.payment_status = new_status
    add_audit_log(
        db,
        actor=actor,
        action="order.payment_updated",
        entity_type="order",
        entity_id=order.id,
        request_id=request_id,
        before=before,
        after={"payment_status": order.payment_status.value},
    )
    db.commit()
    db.refresh(order)
    return order
