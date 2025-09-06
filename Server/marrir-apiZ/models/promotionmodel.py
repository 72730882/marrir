import uuid
from sqlalchemy import Enum, Float, String, ForeignKey, Integer, DECIMAL, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
import enum

from schemas.promotionschema import PromotionStatusSchema

from .base import EntityBaseModel
from .db import Base


class CategoryEnum(enum.Enum):
    promotion = "promotion"
    transfer = "transfer"
    reservation = "reservation"
    employee_process = "employee_process"
    job_application = "job_application"
    employee = "employee"

class RoleEnum(enum.Enum):
    employee = "employee"
    agent = "agent"
    recruitment= "recruitment"
    sponsor = "sponsor"
    selfsponsor = "selfsponsor"

class DurationEnum(enum.Enum):
    ONE_MONTH = "1 month"

    THREE_MONTHS = "3 months"

    SIX_MONTHS = "6 months"

    TWELVE_MONTHS = "12 months"

class PromotionPackagesModel(Base, EntityBaseModel):
    __tablename__ = "table_promotion_packages"
    category: Mapped[CategoryEnum] = mapped_column(Enum(CategoryEnum), nullable=False)
    role: Mapped[RoleEnum] = mapped_column(Enum(RoleEnum), nullable=False)
    duration: Mapped[DurationEnum] = mapped_column(Enum(DurationEnum), nullable=True)
    profile_count: Mapped[int] = mapped_column(Integer, nullable=True)
    price: Mapped[DECIMAL] = mapped_column(DECIMAL, nullable=False)


class PromotionSubscriptionModel(Base, EntityBaseModel):
    __tablename__ = "table_promotion_subscriptions"

    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )

    user = relationship(
        "UserModel", uselist=False, backref="promotion_subscription", foreign_keys=[user_id]
    )

    package_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_promotion_packages.id"), nullable=False
    )

    package = relationship(
        "PromotionPackagesModel", uselist=False, backref="promotion_subscription", foreign_keys=[package_id]
    )

    status: Mapped[str] = mapped_column(String, default=PromotionStatusSchema.ACTIVE)

    start_date: Mapped[DateTime] = mapped_column(DateTime, nullable=True)

    end_date: Mapped[DateTime] = mapped_column(DateTime, nullable=True)

    current_profile_count: Mapped[int] = mapped_column(Integer, default=0)

class PromotionModel(Base, EntityBaseModel):
    __tablename__ = "table_promotions"
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    
    user = relationship(
        "UserModel", uselist=False, backref="promotion", foreign_keys=[user_id]
    )

    promoted_by_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )

    promoted_by = relationship(
        "UserModel", uselist=False, backref="promoted_by", foreign_keys=[promoted_by_id]
    )

    status: Mapped[str] = mapped_column(String, default=PromotionStatusSchema.ACTIVE)

    start_date: Mapped[DateTime] = mapped_column(DateTime, nullable=False)

    end_date: Mapped[DateTime] = mapped_column(DateTime, nullable=False)