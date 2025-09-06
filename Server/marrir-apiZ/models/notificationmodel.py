from datetime import datetime, timezone
from typing import List
import uuid
from sqlalchemy import String, ForeignKey, Boolean
from models.base import EntityBaseModel
from models.db import Base
from sqlalchemy.orm import Mapped, mapped_column, relationship
from models.notificationreadmodel import NotificationReadModel
from models.usernotificationmodel import UserNotificationModel
from sqlalchemy.dialects.postgresql import UUID, JSONB

from schemas.notificationschema import NotificationReceipentTypeSchema


class NotificationModel(Base, EntityBaseModel):
    __tablename__ = "table_notifications"
    receipent_type: Mapped[str] = mapped_column(String, nullable=True)
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str] = mapped_column(String(255))
    type: Mapped[str] = mapped_column(String, nullable=False)
    type_metadata: Mapped[str] = mapped_column(String, nullable=True)
    users_notifications: Mapped[List["UserNotificationModel"]] = relationship(
        "UserNotificationModel", back_populates="notification"
    )
    notification_reads: Mapped[List["NotificationReadModel"]] = relationship(
        "NotificationReadModel", back_populates="notification"
    )


class Notifications(Base):
    __tablename__ = "notifications"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), 
        primary_key=True,
        default=uuid.uuid4,
    )

    title: Mapped[str] = mapped_column(String, nullable=False)

    description: Mapped[str] = mapped_column(String, nullable=False)

    type: Mapped[str] = mapped_column(String, nullable=False)

    object_id = mapped_column(JSONB, nullable=True)

    extra_data = mapped_column(JSONB, nullable=True)

    unread = mapped_column(Boolean, default=True)

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("table_users.id"), nullable=False)
    
    user = relationship("UserModel", backref="notifications", foreign_keys=[user_id])

    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)

    updated_at: Mapped[datetime] = mapped_column(default=None, onupdate=datetime.utcnow, nullable=True)
