from sqlalchemy import Float, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import EntityBaseModel
from .db import Base


class WorkExperienceModel(Base, EntityBaseModel):
    __tablename__ = "table_work_experiences"
    cv_id: Mapped[int] = mapped_column(
        ForeignKey("table_cvs.id", ondelete="CASCADE"), nullable=False
    )
    cv = relationship(
        "CVModel",
        back_populates="work_experiences",
    )

    company_name: Mapped[str] = mapped_column(String(255), nullable=True)
    country: Mapped[str] = mapped_column(String(255), nullable=True)
    city: Mapped[str] = mapped_column(String(255), nullable=True)
    start_date: Mapped[str] = mapped_column(String(255), nullable=True)
    end_date: Mapped[str] = mapped_column(String(255), nullable=True)

    __table_args__ = (
        UniqueConstraint(
            "cv_id", "company_name", "country", "start_date", name="_cv_work_uc"
        ),
    )
