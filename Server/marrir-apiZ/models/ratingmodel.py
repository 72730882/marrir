import uuid
from sqlalchemy import Float, ForeignKey, PrimaryKeyConstraint, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.base import EntityBaseModel
from models.db import Base


class RatingModel(Base, EntityBaseModel):
    __tablename__ = "table_ratings"
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True
    )
    user = relationship("UserModel", backref="rating", foreign_keys=[user_id])
    rated_by: Mapped[str] = mapped_column(
        ForeignKey("table_users.id"), primary_key=True
    )
    rater = relationship("UserModel", backref="rating_giver", foreign_keys=[rated_by])

    type: Mapped[str] = mapped_column(String)
    value: Mapped[float] = mapped_column(Float, nullable=False)
    description: Mapped[str] = mapped_column(String(255), nullable=True)

    __table_args__ = (UniqueConstraint("id", "rated_by", name="uix_id_rated_by"),)
