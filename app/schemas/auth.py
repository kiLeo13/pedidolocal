from datetime import date

from pydantic import BaseModel, EmailStr, Field, field_validator

from app.schemas.users import UserResponse
from app.schemas.validation import (
    clean_text,
    validate_birth_date,
    validate_password_strength,
    validate_phone,
)


class CustomerRegisterRequest(BaseModel):
    email: EmailStr = Field(max_length=255)
    password: str = Field(min_length=8, max_length=128)
    full_name: str = Field(min_length=2, max_length=120)
    phone: str = Field(min_length=8, max_length=30)
    address_line: str = Field(min_length=5, max_length=255)
    city: str = Field(min_length=2, max_length=120)
    birth_date: date | None = None

    @field_validator("password")
    @classmethod
    def password_must_be_strong(cls, value: str) -> str:
        return validate_password_strength(value)

    @field_validator("full_name", "address_line", "city", mode="before")
    @classmethod
    def text_must_be_safe(cls, value):
        return clean_text(value)

    @field_validator("phone", mode="before")
    @classmethod
    def phone_must_be_safe(cls, value):
        return validate_phone(value)

    @field_validator("birth_date")
    @classmethod
    def birth_date_must_be_plausible(cls, value: date | None) -> date | None:
        return validate_birth_date(value)


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class AuthenticatedUserResponse(UserResponse):
    pass
