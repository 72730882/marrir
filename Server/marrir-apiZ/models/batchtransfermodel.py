from typing import Any, List
import uuid

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from schemas.transferschema import TransferStatusSchema

from .base import EntityBaseModel
from .db import Base
from sqlalchemy import String


class BatchTransferModel(Base, EntityBaseModel):
    __tablename__ = "table_batch_transfers"
    receiver_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    requester_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    receiver = relationship(
        "UserModel", foreign_keys=[receiver_id], backref="batch_transfer_receiver"
    )
    requester = relationship(
        "UserModel", foreign_keys=[requester_id], backref="batch_transfer_requester"
    )
    transfers = relationship("TransferRequestModel", back_populates="batch_transfer")
