import uuid
from sqlalchemy import Boolean, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from models.base import EntityBaseModel
from models.db import Base

class UserNotificationModel(Base, EntityBaseModel):
    __tablename__="table_user_notifications"
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("table_users.id"))
    notification_id: Mapped[int] = mapped_column(ForeignKey("table_notifications.id"))
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    notification = relationship("NotificationModel", back_populates="users_notifications", foreign_keys=[notification_id])
    user = relationship("UserModel", back_populates="user_notifications", foreign_keys=[user_id])
    