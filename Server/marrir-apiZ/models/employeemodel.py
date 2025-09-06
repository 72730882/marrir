import uuid
from sqlalchemy import Boolean, Float, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from schemas.userschema import EmployeeStatusTypeSchema
from .base import EntityBaseModel
from .db import Base


class EmployeeModel(Base, EntityBaseModel):
    __tablename__ = "table_employees"
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True, nullable=False
    )
    manager_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True, nullable=False
    )
    cv_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    status: Mapped[str] = mapped_column(String, default=EmployeeStatusTypeSchema.INCOMPLETE)
    employee = relationship(
        "UserModel", back_populates="employees", foreign_keys=[user_id]
    )
