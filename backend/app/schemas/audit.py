from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class AuditLogResponse(BaseModel):
    id: int
    actor_user_id: int | None
    action: str
    entity_type: str
    entity_id: str | None
    request_id: str
    before: dict[str, Any] | None
    after: dict[str, Any] | None
    metadata: dict[str, Any] | None = Field(
        default=None,
        validation_alias="log_metadata",
        serialization_alias="metadata",
    )
    created_at: datetime

    model_config = ConfigDict(from_attributes=True, populate_by_name=True)
