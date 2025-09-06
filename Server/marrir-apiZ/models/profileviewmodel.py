import uuid
from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from .base import EntityBaseModel
from .db import Base


class ProfileViewModel(Base, EntityBaseModel):
    __tablename__ = "table_profile_views"
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True, nullable=False
    )
    profile_viewer_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True, nullable=False
    )
