import uuid
from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.base import EntityBaseModel
from models.db import Base
from schemas.offerschema import OfferTypeSchema


class OfferModel(Base, EntityBaseModel):
    __tablename__ = "table_offers"
    receiver_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    job_id: Mapped[int] = mapped_column(ForeignKey("table_jobs.id"), nullable=False)
    sponsor_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    detail: Mapped[str] = mapped_column(String(255))
    offer_status: Mapped[str] = mapped_column(
        String(255), default=OfferTypeSchema.PENDING
    )
    receiver = relationship(
        "UserModel", back_populates="received_offers", foreign_keys=[receiver_id]
    )
    sponsor = relationship(
        "UserModel", back_populates="sent_offers", foreign_keys=[sponsor_id]
    )
    job = relationship("JobModel", backref="offers")
