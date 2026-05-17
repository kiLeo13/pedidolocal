from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.schemas.validation import (
    MAX_ENTITY_ID,
    MAX_MONEY,
    MAX_STOCK,
    clean_optional_text,
    clean_text,
)


class CategoryCreate(BaseModel):
    name: str = Field(min_length=2, max_length=80)
    description: str | None = Field(default=None, max_length=1000)

    @field_validator("name", mode="before")
    @classmethod
    def name_must_be_safe(cls, value):
        return clean_text(value)

    @field_validator("description", mode="before")
    @classmethod
    def description_must_be_safe(cls, value):
        return clean_optional_text(value, allow_multiline=True)


class CategoryUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=80)
    description: str | None = Field(default=None, max_length=1000)
    is_active: bool | None = None

    @field_validator("name", mode="before")
    @classmethod
    def name_must_be_safe(cls, value):
        return clean_optional_text(value)

    @field_validator("description", mode="before")
    @classmethod
    def description_must_be_safe(cls, value):
        return clean_optional_text(value, allow_multiline=True)


class CategoryResponse(BaseModel):
    id: int
    name: str
    description: str | None
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ProductCreate(BaseModel):
    category_id: int = Field(gt=0, le=MAX_ENTITY_ID)
    name: str = Field(min_length=2, max_length=120)
    description: str | None = Field(default=None, max_length=1000)
    price: Decimal = Field(ge=0, le=MAX_MONEY, max_digits=7, decimal_places=2)
    stock: int = Field(ge=0, le=MAX_STOCK)
    is_active: bool = True
    is_alcoholic: bool = False

    @field_validator("name", mode="before")
    @classmethod
    def name_must_be_safe(cls, value):
        return clean_text(value)

    @field_validator("description", mode="before")
    @classmethod
    def description_must_be_safe(cls, value):
        return clean_optional_text(value, allow_multiline=True)


class ProductUpdate(BaseModel):
    category_id: int | None = Field(default=None, gt=0, le=MAX_ENTITY_ID)
    name: str | None = Field(default=None, min_length=2, max_length=120)
    description: str | None = Field(default=None, max_length=1000)
    price: Decimal | None = Field(
        default=None,
        ge=0,
        le=MAX_MONEY,
        max_digits=7,
        decimal_places=2,
    )
    stock: int | None = Field(default=None, ge=0, le=MAX_STOCK)
    is_active: bool | None = None
    is_alcoholic: bool | None = None

    @field_validator("name", mode="before")
    @classmethod
    def name_must_be_safe(cls, value):
        return clean_optional_text(value)

    @field_validator("description", mode="before")
    @classmethod
    def description_must_be_safe(cls, value):
        return clean_optional_text(value, allow_multiline=True)


class ProductResponse(BaseModel):
    id: int
    category_id: int
    name: str
    description: str | None
    price: Decimal
    stock: int
    is_active: bool
    is_alcoholic: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
