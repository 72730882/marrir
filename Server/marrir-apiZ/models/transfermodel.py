from typing import Any, List
import uuid

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from schemas.transferschema import TransferStatusSchema

from .base import EntityBaseModel
from .db import Base
from sqlalchemy import String


class TransferModel(Base, EntityBaseModel):
    __tablename__ = "table_transfers"
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    manager_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    previous_manager_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=True
    )
    user = relationship(
        "UserModel", uselist=False, backref="user", foreign_keys=[user_id]
    )
    manager = relationship(
        "UserModel", uselist=False, backref="manager", foreign_keys=[manager_id]
    )
    previous_manager = relationship(
        "UserModel",
        uselist=False,
        backref="previous_manager",
        foreign_keys=[previous_manager_id],
    )
