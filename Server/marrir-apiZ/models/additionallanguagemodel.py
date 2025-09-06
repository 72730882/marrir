from sqlalchemy import ForeignKey, String, UniqueConstraint
from models.base import EntityBaseModel
from models.cvmodel import CVModel
from models.db import Base
from sqlalchemy.orm import Mapped, mapped_column, relationship


class AdditionalLanguageModel(Base, EntityBaseModel):
    __tablename__ = "table_additional_languages"
    cv_id: Mapped[int] = mapped_column(ForeignKey("table_cvs.id"), nullable=False)
    language: Mapped[str] = mapped_column(String, nullable=False)
    proficiency: Mapped[str] = mapped_column(String, nullable=False)
    cv = relationship(
        CVModel, back_populates="additional_languages", lazy="select"
    )

    __table_args__ = (UniqueConstraint("cv_id", "language", name="uix_cv_id_language"),)
