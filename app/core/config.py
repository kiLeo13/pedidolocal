from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Pedido Local API"
    database_url: str = "sqlite:///./pedidolocal.db"
    jwt_secret_key: str = Field(
        default="change-this-development-secret-key-before-running",
        min_length=16,
    )
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = Field(default=30, gt=0)
    allowed_city: str = "Pedido Local"
    environment: str = "development"
    max_request_body_bytes: int = Field(default=1_048_576, gt=0)

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
