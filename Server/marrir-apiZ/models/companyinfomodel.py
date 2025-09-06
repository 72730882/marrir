import uuid
from sqlalchemy import ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import EntityBaseModel
from .db import Base
from pydantic import BaseModel, EmailStr
import uuid

class CompanyInfoModel(Base, EntityBaseModel):
    __tablename__ = "table_company_infos"
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("table_users.id"), nullable=False)
    company_name: Mapped[str] = mapped_column(String(255), nullable=False)
    alternative_email: Mapped[str] = mapped_column(String(255), nullable=False)
    alternative_phone: Mapped[str] = mapped_column(String(255), nullable=False)
    location: Mapped[str] = mapped_column(String(255), nullable=False)
    year_established: Mapped[int] = mapped_column(Integer, nullable=False)
    ein_tin: Mapped[str] = mapped_column(String(255), nullable=True)
    company_license: Mapped[str] = mapped_column(String(255), nullable=True)
    company_logo: Mapped[str] = mapped_column(String(255), nullable=True)
    user = relationship("UserModel", back_populates="company")

class CompanyInfoData(BaseModel):
    user_id: uuid.UUID
    alternative_email: EmailStr
    alternative_phone: str
    company_name: str
    ein_tin: str | None = None
    location: str
    year_established: int