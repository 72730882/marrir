import uuid
from sqlalchemy import Float, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import EntityBaseModel
from .db import Base

class InvoiceModel(Base, EntityBaseModel):
    __tablename__ = "table_invoices"
    customer_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=True
    )
    stripe_session_id: Mapped[str] = mapped_column(String(255), nullable=True)
    status: Mapped[str] = mapped_column(String(255), default="unpaid")
    amount: Mapped[float] = mapped_column(Float())
    currency: Mapped[str] = mapped_column(String, default="aed")
    type: Mapped[str] = mapped_column(String, nullable=True)
    buyer_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("table_users.id"), nullable=True)
    object_id: Mapped[str] = mapped_column(String, nullable=True)
    card = mapped_column(String, nullable=True)
    description = mapped_column(String, nullable=True)
