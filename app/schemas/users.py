from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, EmailStr

from app.models import Role


class CustomerProfileResponse(BaseModel):
    phone: str
    address_line: str
    city: str
    birth_date: date | None

    model_config = ConfigDict(from_attributes=True)


class UserResponse(BaseModel):
    id: int
    email: EmailStr
    full_name: str
    role: Role
    is_active: bool
    created_at: datetime
    profile: CustomerProfileResponse | None = None

    model_config = ConfigDict(from_attributes=True)
