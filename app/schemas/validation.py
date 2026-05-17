from datetime import date
from decimal import Decimal
from typing import Any
from unicodedata import category

ALLOWED_MULTILINE_CONTROL_CHARS = {"\n", "\r", "\t"}
MIN_BIRTH_DATE = date(1900, 1, 1)
MAX_MONEY = Decimal("99999.99")
MAX_STOCK = 100_000
MAX_ENTITY_ID = 2_147_483_647


def clean_text(value: Any, *, allow_multiline: bool = False) -> str:
    if not isinstance(value, str):
        raise ValueError("must be a text value")
    cleaned = value.strip()
    if not cleaned:
        raise ValueError("must not be blank")
    for char in cleaned:
        if category(char).startswith("C") and (
            not allow_multiline or char not in ALLOWED_MULTILINE_CONTROL_CHARS
        ):
            raise ValueError("must not contain control characters")
    return cleaned


def clean_optional_text(value: Any, *, allow_multiline: bool = False) -> str | None:
    if value is None:
        return None
    return clean_text(value, allow_multiline=allow_multiline)


def validate_password_strength(password: str) -> str:
    if password.strip() != password:
        raise ValueError("password must not start or end with whitespace")
    if not any(char.islower() for char in password):
        raise ValueError("password must contain at least one lowercase letter")
    if not any(char.isupper() for char in password):
        raise ValueError("password must contain at least one uppercase letter")
    if not any(char.isdigit() for char in password):
        raise ValueError("password must contain at least one digit")
    return password


def validate_phone(phone: str) -> str:
    cleaned = clean_text(phone)
    allowed = set("+0123456789 ()-")
    if any(char not in allowed for char in cleaned):
        raise ValueError("phone may contain only digits, spaces, +, -, and parentheses")
    digits = [char for char in cleaned if char.isdigit()]
    if not 8 <= len(digits) <= 15:
        raise ValueError("phone must contain between 8 and 15 digits")
    return cleaned


def validate_birth_date(value: date | None) -> date | None:
    if value is None:
        return None
    if value < MIN_BIRTH_DATE:
        raise ValueError("birth_date must be on or after 1900-01-01")
    if value > date.today():
        raise ValueError("birth_date must not be in the future")
    return value
