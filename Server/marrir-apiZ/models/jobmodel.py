import uuid
from sqlalchemy import ForeignKey, Integer, String, Boolean
from models.base import EntityBaseModel
from models.db import Base
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.jobapplicationmodel import JobApplicationModel
from models.usermodel import UserModel

class JobModel(Base, EntityBaseModel):
    __tablename__ = "table_jobs"
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(String(255), nullable=True)
    location: Mapped[str] = mapped_column(String(255), nullable=True)
    education_status: Mapped[str] = mapped_column(String(255), nullable=True)
    amount: Mapped[int] = mapped_column(Integer, default=1, nullable=True)
    occupation: Mapped[str] = mapped_column(String, nullable=True)
    type: Mapped[str] = mapped_column(String(255), nullable=False)
    posted_by: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    job_poster = relationship(UserModel, backref="job_poster")
    job_applications = relationship(JobApplicationModel, backref="job")
    is_open: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)