from sqlalchemy import Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.cvmodel import CVModel
from .base import EntityBaseModel
from .db import Base


class AddressModel(Base, EntityBaseModel):
    __tablename__ = "table_addresses"
    country: Mapped[str] = mapped_column(String(50), nullable=True)
    region: Mapped[str] = mapped_column(String(50), nullable=True)
    city: Mapped[str] = mapped_column(String(50), nullable=True)
    street3: Mapped[str] = mapped_column(String(50), nullable=True)
    street2: Mapped[str] = mapped_column(String(50), nullable=True)
    street: Mapped[str] = mapped_column(String(50), nullable=True)
    house_no: Mapped[str] = mapped_column(String(50), nullable=True)
    po_box: Mapped[int] = mapped_column(Integer, nullable=True)
    zip_code: Mapped[str] = mapped_column(String(50), nullable=True)
    cv = relationship(
        CVModel, back_populates="address", lazy="select"
    )
