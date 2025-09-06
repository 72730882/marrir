import uuid
from sqlalchemy import Float, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from schemas.transferschema import TransferStatusSchema
from .base import EntityBaseModel
from .db import Base


class TransferRequestModel(Base, EntityBaseModel):
    __tablename__ = "table_transfer_requests"
    batch_id: Mapped[int] = mapped_column(
        ForeignKey("table_batch_transfers.id"), primary_key=True, nullable=False
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True, nullable=False
    )
    requester_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True, nullable=False
    )
    manager_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True, nullable=False
    )
    status: Mapped[str] = mapped_column(
        String, nullable=False, default=TransferStatusSchema.PENDING
    )
    reason: Mapped[str] = mapped_column(String(255), nullable=True)
    batch_transfer = relationship("BatchTransferModel", back_populates="transfers")
    user = relationship(
        "UserModel", backref="transfer_request", lazy="select", foreign_keys=[user_id]
    )
    requester = relationship(
        "UserModel", backref="transfer_requester", lazy="select", foreign_keys=[requester_id]
    )
    manager = relationship(
        "UserModel",
        backref="transfer_request_manager",
        lazy="select",
        foreign_keys=[manager_id],
    )
