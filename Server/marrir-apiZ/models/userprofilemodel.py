from typing import List
import uuid

from sqlalchemy import ForeignKey, LargeBinary
from sqlalchemy.orm import Mapped, mapped_column, relationship

from schemas.paymentschema import PaymentBaseSchema
from .base import EntityBaseModel
from .db import Base


class UserProfileModel(Base, EntityBaseModel):
    __tablename__ = "table_user_profiles"
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), unique=True, nullable=False
    )
    qr_code = mapped_column(LargeBinary)
    payments: Mapped[List[PaymentBaseSchema]] = relationship(
        "PaymentModel", back_populates="user_profile"
    )
