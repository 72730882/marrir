from typing import Any, Dict, List, Optional, Union
from sqlalchemy import BinaryExpression
from sqlalchemy.orm import Session
from models.usernotificationmodel import UserNotificationModel

from repositories.base import (
    BaseRepository,
    CreateSchemaType,
    EntityType,
    FilterSchemaType,
    UpdateSchemaType,
)
from schemas.notificationschema import UserNotificationBaseSchema


class UserNotificationRepository(
    BaseRepository[
        UserNotificationModel, UserNotificationBaseSchema, UserNotificationBaseSchema
    ]
):
    def create(self, db: Session, *, obj_in: CreateSchemaType) -> EntityType | None:
        return super().create(db, obj_in=obj_in)