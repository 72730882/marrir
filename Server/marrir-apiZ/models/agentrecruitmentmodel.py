import uuid
from sqlalchemy import ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from schemas.enumschema import OfferTypeSchema

from .base import EntityBaseModel
from .db import Base


class AgentRecruitmentModel(Base, EntityBaseModel):
    __tablename__ = "table_agent_recruitments"
    agent_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True, nullable=False
    )
    recruitment_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True, nullable=False
    )
    agent = relationship(
        "UserModel",
        foreign_keys=[agent_id],
    )
    recruitment = relationship(
        "UserModel",
        foreign_keys=[recruitment_id],
    )
    status: Mapped[str] = mapped_column(String, default=OfferTypeSchema.PENDING)
    document_url: Mapped[str] = mapped_column(String, nullable=True)