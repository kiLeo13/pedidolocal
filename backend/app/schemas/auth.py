from datetime import date

from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator

from app.models import Role
from app.schemas.users import UserResponse
from app.schemas.validation import (
    clean_optional_text,
    clean_text,
    validate_birth_date,
    validate_password_strength,
    validate_phone,
)


class CustomerRegisterRequest(BaseModel):
    email: EmailStr = Field(max_length=255)
    password: str = Field(min_length=8, max_length=128)
    full_name: str = Field(min_length=2, max_length=120)
    role: Role = Role.CUSTOMER
    phone: str | None = Field(default=None, min_length=8, max_length=30)
    address_line: str | None = Field(default=None, min_length=5, max_length=255)
    city: str | None = Field(default=None, min_length=2, max_length=120)
    birth_date: date | None = None

    @field_validator("password")
    @classmethod
    def password_must_be_strong(cls, value: str) -> str:
        return validate_password_strength(value)

    @field_validator("full_name", mode="before")
    @classmethod
    def text_must_be_safe(cls, value):
        return clean_text(value)

    @field_validator("address_line", "city", mode="before")
    @classmethod
    def optional_text_must_be_safe(cls, value):
        return clean_optional_text(value)

    @field_validator("phone", mode="before")
    @classmethod
    def phone_must_be_safe(cls, value):
        if value is None:
            return None
        return validate_phone(value)

    @field_validator("birth_date")
    @classmethod
    def birth_date_must_be_plausible(cls, value: date | None) -> date | None:
        return validate_birth_date(value)

    @model_validator(mode="after")
    def customer_profile_fields_are_required(self):
        if self.role == Role.CUSTOMER and (
            self.phone is None or self.address_line is None or self.city is None
        ):
            raise ValueError("customer accounts require phone, address_line, and city")
        return self


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class AuthenticatedUserResponse(UserResponse):
    pass
