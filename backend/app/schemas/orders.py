from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.models import OrderStatus, PaymentMethod, PaymentStatus
from app.schemas.validation import MAX_ENTITY_ID, clean_text


class OrderItemCreate(BaseModel):
    product_id: int = Field(gt=0, le=MAX_ENTITY_ID)
    quantity: int = Field(gt=0, le=100)


class OrderCreate(BaseModel):
    items: list[OrderItemCreate] = Field(min_length=1, max_length=50)
    payment_method: PaymentMethod
    delivery_city: str = Field(min_length=2, max_length=120)
    delivery_address: str = Field(min_length=5, max_length=255)

    @field_validator("delivery_city", "delivery_address", mode="before")
    @classmethod
    def delivery_text_must_be_safe(cls, value):
        return clean_text(value)

    @field_validator("items")
    @classmethod
    def product_ids_must_be_unique(cls, items: list[OrderItemCreate]) -> list[OrderItemCreate]:
        product_ids = [item.product_id for item in items]
        if len(product_ids) != len(set(product_ids)):
            raise ValueError("duplicate products are not allowed in the same order")
        return items


class OrderItemResponse(BaseModel):
    id: int
    product_id: int
    product_name_snapshot: str
    unit_price: Decimal
    quantity: int
    line_total: Decimal

    model_config = ConfigDict(from_attributes=True)


class OrderResponse(BaseModel):
    id: int
    customer_id: int
    status: OrderStatus
    payment_method: PaymentMethod
    payment_status: PaymentStatus
    delivery_city: str
    delivery_address: str
    subtotal: Decimal
    stock_restored: bool
    created_at: datetime
    updated_at: datetime
    canceled_at: datetime | None
    delivered_at: datetime | None
    items: list[OrderItemResponse]

    model_config = ConfigDict(from_attributes=True)


class OrderStatusUpdate(BaseModel):
    status: OrderStatus


class PaymentStatusUpdate(BaseModel):
    payment_status: PaymentStatus
