import uuid
from sqlalchemy import ForeignKey
from models.base import EntityBaseModel
from models.db import Base
from sqlalchemy.orm import Mapped, mapped_column, relationship

class NotificationReadModel(Base, EntityBaseModel):
    __tablename__ = "table_notification_reads"
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("table_users.id"), primary_key=True)
    notification_id: Mapped[int] = mapped_column(ForeignKey("table_notifications.id"), primary_key=True)
    notification = relationship("NotificationModel", back_populates="notification_reads", foreign_keys=[notification_id])
    user = relationship("UserModel", back_populates="notification_reads", foreign_keys=[user_id])