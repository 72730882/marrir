from typing import Any, List
import uuid

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from schemas.transferschema import TransferStatusSchema

from .base import EntityBaseModel
from .db import Base
from sqlalchemy import String


class BatchReserveModel(Base, EntityBaseModel):
    __tablename__ = "table_batch_reserves"
    reserver_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("table_users.id"), nullable=False)
    reserver = relationship(
        "UserModel", foreign_keys=[reserver_id], backref="batch_reserve_reserver"
    )
    reserves = relationship("ReserveModel", back_populates="batch_reserve")