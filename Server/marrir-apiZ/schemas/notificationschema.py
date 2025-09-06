from datetime import datetime
from enum import Enum, unique
from typing import Any, List, Optional, TypeVar
import uuid

from pydantic import BaseModel

from schemas.base import BaseProps
from schemas.enumschema import NotificationReceipentTypeSchema, NotificationTypeSchema


class NotificationBaseSchema(BaseProps):
    receipent_type: Optional[NotificationReceipentTypeSchema] = None
    title: Optional[str] = None
    description: Optional[str] = None
    type: Optional[NotificationTypeSchema] = None
    type_metadata: Optional[Any] = None

class SeenNotificationBaseSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    notification_id: Optional[int] = None

class UserNotificationBaseSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    notification_id: Optional[int] = None
    is_read: bool = False

EntityBaseSchema = TypeVar("EntityBaseSchema", bound=NotificationBaseSchema)


class NotificationCreateSchema(NotificationBaseSchema):
    receipent_ids: List[uuid.UUID]

class NotificationReadSchema(NotificationBaseSchema):
    id: int
    notification_reads: Optional[List[SeenNotificationBaseSchema]] = []
    users: Optional[List[UserNotificationBaseSchema]] = []

class SingleUserNotificationReadSchema(BaseProps):
    id: int
    title: str
    type: NotificationTypeSchema
    description: str
    is_read: Optional[bool] = False
    type_metadata: Optional[Any] = None
    created_at: Optional[datetime] = None

class TotalNotificationSchema(BaseProps):
    notifications: List[SingleUserNotificationReadSchema] = []
    unread_count: int = 0


class NotificationSchema(BaseModel):
    id: uuid.UUID

    title: str

    description: str

    type: str

    object_id: Any | None

    extra_data: Any | None

    unread: bool

    created_at: datetime

    updated_at: datetime | None