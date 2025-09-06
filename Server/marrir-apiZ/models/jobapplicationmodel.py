import uuid
from sqlalchemy import ForeignKey, String, UniqueConstraint
from models.base import EntityBaseModel
from models.db import Base
from sqlalchemy.orm import Mapped, mapped_column, relationship

from schemas.offerschema import OfferTypeSchema


class JobApplicationModel(Base, EntityBaseModel):
    __tablename__ = "table_job_applications"
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("table_users.id"))
    job_id: Mapped[int] = mapped_column(ForeignKey("table_jobs.id"))
    status: Mapped[str] = mapped_column(String, default=OfferTypeSchema.PENDING)
    user = relationship("UserModel", back_populates="job_applications")

    __table_args__ = (UniqueConstraint("user_id", "job_id", name="uix_user_id_job_id"),)
