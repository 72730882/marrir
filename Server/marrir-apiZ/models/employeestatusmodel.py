import uuid
from sqlalchemy import VARCHAR, Float, ForeignKey, Integer, String, Unicode
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import EntityBaseModel
from .db import Base


class EmployeeStatusModel(Base, EntityBaseModel):
    __tablename__ = "table_employee_statuses"
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    status: Mapped[str] = mapped_column(String, nullable=False)
    reason: Mapped[str] = mapped_column(String(1000), nullable=True)
