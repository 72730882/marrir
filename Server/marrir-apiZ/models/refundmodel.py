from sqlalchemy import Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.base import EntityBaseModel
from models.db import Base
from schemas.enumschema import RefundStatusSchema


class RefundModel(Base, EntityBaseModel):
    __tablename__ = "table_refunds"
    payment_id: Mapped[int] = mapped_column(ForeignKey("table_payments.id"))
    status: Mapped[bool] = mapped_column(String(255), default=RefundStatusSchema.PENDING)
    reason: Mapped[str] = mapped_column(String(255), nullable=False)
