from sqlalchemy import Float, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import EntityBaseModel
from .db import Base


class ReferenceModel(Base, EntityBaseModel):
    __tablename__ = "table_references"
    cv_id: Mapped[int] = mapped_column(
        ForeignKey("table_cvs.id", ondelete="CASCADE"), nullable=False
    )
    name: Mapped[str] = mapped_column(String(255), nullable=True)
    phone_number: Mapped[str] = mapped_column(String(255), nullable=True)
    email: Mapped[str] = mapped_column(String(255), nullable=True)
    birth_date: Mapped[str] = mapped_column(String(255), nullable=True)
    gender: Mapped[str] = mapped_column(String(255), nullable=True)
    country: Mapped[str] = mapped_column(String(255), nullable=True)
    city: Mapped[str] = mapped_column(String(255), nullable=True)
    sub_city: Mapped[str] = mapped_column(String(255), nullable=True)
    zone: Mapped[str] = mapped_column(String(255), nullable=True)
    po_box: Mapped[int] = mapped_column(Integer, nullable=True)
    house_no: Mapped[str] = mapped_column(String(255), nullable=True)
    cv = relationship(
        "CVModel",
        back_populates="references",
    )

    __table_args__ = (
        UniqueConstraint("cv_id", "phone_number", name="_cv_phone_number_uc"),
    )
