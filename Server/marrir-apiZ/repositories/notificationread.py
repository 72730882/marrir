from typing import Any, Dict, List, Optional, Union
from fastapi.encoders import jsonable_encoder

from sqlalchemy import BinaryExpression
from sqlalchemy.orm import Session
from models.notificationreadmodel import NotificationReadModel

from repositories.base import (
    BaseRepository,
    CreateSchemaType,
    EntityType,
    FilterSchemaType,
    UpdateSchemaType,
)
from schemas.notificationschema import SeenNotificationBaseSchema


class NotificationReadRepository(
    BaseRepository[
        NotificationReadModel, SeenNotificationBaseSchema, SeenNotificationBaseSchema
    ]
):
    def get_some(
        self, db: Session, skip: int, limit: int, filters: FilterSchemaType
    ) -> List[EntityType]:
        return super().get_some(db, skip, limit, filters)

    def create(self, db: Session, *, obj_in: CreateSchemaType) -> EntityType | None:
        return super().create(db, obj_in=obj_in)