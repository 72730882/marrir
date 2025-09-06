import uuid
from sqlalchemy import Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.cvmodel import CVModel
from schemas.enumschema import TransferStatusSchema
from schemas.userschema import UserReadSchema
from .base import EntityBaseModel
from .db import Base


class StartedAgentProcessModel(Base, EntityBaseModel):
    __tablename__ = "table_started_agent_processes"
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    agent_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    assign_agent_id: Mapped[int] = mapped_column(
        ForeignKey("table_assign_agents.id"), nullable=True
    )
    user: Mapped["UserReadSchema"] = relationship(
        "UserModel",
        foreign_keys=[user_id],
        backref="started_process_user",
    )
    agent: Mapped["UserReadSchema"] = relationship(
        "UserModel",
        foreign_keys=[agent_id],
        backref="started_process_agent",
    )
    assign_agent = relationship(
        "AssignAgentModel",
        foreign_keys=[assign_agent_id],
        backref="started_process_assign_agent",
    )
