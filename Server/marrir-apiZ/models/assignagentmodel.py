import uuid
from sqlalchemy import Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.cvmodel import CVModel
from schemas.enumschema import TransferStatusSchema
from schemas.userschema import UserReadSchema
from .base import EntityBaseModel
from .db import Base


class AssignAgentModel(Base, EntityBaseModel):
    __tablename__ = "table_assign_agents"
    process_id: Mapped[int] = mapped_column(
        ForeignKey("table_processes.id"), nullable=False
    )
    agent_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    requester_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    status: Mapped[str] = mapped_column(String, default=TransferStatusSchema.PENDING)
    reason: Mapped[str] = mapped_column(String(255), nullable=True)
    agent: Mapped["UserReadSchema"] = relationship(
        "UserModel",
        foreign_keys=[agent_id],
        backref="assignment_agent",
    )
    requester: Mapped["UserReadSchema"] = relationship(
        "UserModel",
        foreign_keys=[requester_id],
        backref="assignment_requester",
    )
    user: Mapped["UserReadSchema"] = relationship(
        "UserModel",
        foreign_keys=[user_id],
        backref="assignment_user",
    )
