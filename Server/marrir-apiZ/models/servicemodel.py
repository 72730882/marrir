from sqlalchemy import Boolean, Float, String
from sqlalchemy.orm import Mapped, mapped_column

from .base import EntityBaseModel
from .db import Base


class ServiceModel(Base, EntityBaseModel):
    __tablename__ = "table_services"
    name: Mapped[str] = mapped_column(String, index=True, nullable=False)
    description: Mapped[str] = mapped_column(String(255), nullable=True)
    stripe_product_id: Mapped[str] = mapped_column(String, nullable=False)
    stripe_price_id: Mapped[str] = mapped_column(String, unique=True, index=True)
    recurring: Mapped[bool] = mapped_column(Boolean, default=False)
    amount: Mapped[float] = mapped_column(Float)