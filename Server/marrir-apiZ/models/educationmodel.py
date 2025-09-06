from sqlalchemy import Float, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import EntityBaseModel
from .db import Base


class EducationModel(Base, EntityBaseModel):
    __tablename__ = "table_educations"
    cv_id: Mapped[int] = mapped_column(
        ForeignKey("table_cvs.id", ondelete="CASCADE"), nullable=False
    )
    cv = relationship("CVModel", back_populates="education")

    highest_level: Mapped[str] = mapped_column(String(255), nullable=True)
    institution_name: Mapped[str] = mapped_column(String(255), nullable=True)
    country: Mapped[str] = mapped_column(String(255), nullable=True)
    city: Mapped[str] = mapped_column(String(255), nullable=True)
    grade: Mapped[str] = mapped_column(String(255), nullable=True)
