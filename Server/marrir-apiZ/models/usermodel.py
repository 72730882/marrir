from datetime import datetime
from typing import Any, List
import uuid
from sqlalchemy.orm import Session

from sqlalchemy import event
from sqlalchemy import Date, ForeignKey, String
from sqlalchemy import TypeDecorator, Text
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID as pgUUID
from core.security import get_password_hash
from models.jobapplicationmodel import JobApplicationModel
from models.notificationmodel import Notifications
from models.notificationreadmodel import NotificationReadModel
from models.offermodel import OfferModel
from models.usernotificationmodel import UserNotificationModel
from schemas.offerschema import OfferBaseSchema
from .base import EntityBaseModel
from .db import Base, get_db_session


class PasswordInModel(TypeDecorator):
    """Allows storing and retrieving password hashes using PasswordHash."""

    impl = Text

    def __init__(self, *args: Any, **kwds):
        super().__init__(*args, **kwds)

    def process_bind_param(self, value, dialect):
        """Ensure the value is a PasswordHash and then return its hash."""
        return self._convert(value)

    def process_result_value(self, value, dialect):
        """Convert the hash to a PasswordHash, if it's non-NULL."""
        if value is not None:
            return value

    def validator(self, password):
        """Provides a validator/converter for @validates usage."""
        return self._convert(password)

    @staticmethod
    def _convert(value):
        if value is not None:
            return get_password_hash(value)
        return None


class UserModel(Base, EntityBaseModel):
    __tablename__ = "table_users"
    id: Mapped[uuid.UUID] = mapped_column(
        pgUUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    first_name: Mapped[str] = mapped_column(String(255), nullable=True)
    last_name: Mapped[str] = mapped_column(String(255), nullable=True)
    email: Mapped[str] = mapped_column(
        String(255), unique=True, index=True, nullable=True
    )
    phone_number: Mapped[str] = mapped_column(
        String(255), unique=True, index=True, nullable=True
    )
    country: Mapped[str] = mapped_column(String(255), nullable=True)
    password: Mapped[PasswordInModel] = mapped_column(PasswordInModel, nullable=True)
    role: Mapped[str] = mapped_column(String(255), nullable=False)
    verified: Mapped[bool] = mapped_column(default=True)  # default revert back to false
    disabled: Mapped[bool] = mapped_column(default=False)  # default revert back to false
    stripe_customer_id: Mapped[str] = mapped_column(String, unique=True, nullable=True)
    google_id: Mapped[str] = mapped_column(String, unique=True, nullable=True)
    profile = relationship("UserProfileModel", uselist=False, backref="user")

    terms_file_path: Mapped[str] = mapped_column(String(512), nullable=True)
    is_uploaded: Mapped[bool] = mapped_column(default=False)
    is_admin_approved: Mapped[bool] = mapped_column(default=False)
    is_admin_rejected: Mapped[bool] = mapped_column(default=False)
    passport_number: Mapped[str] = mapped_column(
        ForeignKey("table_cvs.passport_number"), nullable=True
    )
    otp: Mapped[str] = mapped_column(String, nullable=True)
    otp_expiry: Mapped[datetime] = mapped_column(nullable=True)
    cv = relationship(
        "CVModel", uselist=False, backref="user", foreign_keys="[CVModel.user_id]"
    )
    process = relationship(
        "ProcessModel",
        uselist=False,
        backref="user",
        foreign_keys="[ProcessModel.user_id]",
    )

    company = relationship("CompanyInfoModel", back_populates="user", uselist=False)
    received_offers: Mapped[List[OfferBaseSchema]] = relationship(
        OfferModel,
        back_populates="receiver",
        foreign_keys="[OfferModel.receiver_id]",
        lazy="select",
    )
    sent_offers: Mapped[List[OfferBaseSchema]] = relationship(
        OfferModel,
        back_populates="sponsor",
        foreign_keys="[OfferModel.sponsor_id]",
        lazy="select",
    )
    user_notifications = relationship(
        "UserNotificationModel", back_populates="user", lazy="select"
    )
    notification_reads = relationship(
        "NotificationReadModel", back_populates="user", lazy="select"
    )
    job_applications = relationship(
        JobApplicationModel, cascade="all, delete", back_populates="user", lazy="select"
    )
    employees = relationship(
        "EmployeeModel",
        back_populates="employee",
        foreign_keys="EmployeeModel.user_id",
        lazy="select",
    )

    @hybrid_property
    def owner_id(self):
        return self.email



@event.listens_for(UserModel, 'after_insert')
def after_insert_trigger(mapper, connection, target: UserModel):
    session = Session(bind=connection)    
    notification = Notifications(
        title="Welcome to the platform",
        description="You can use our portal to promote yourself, apply for jobs and have a better future",
        type="welcome",
        user_id=target.id
    )

    session.add(notification)
    
    try:
        session.commit()
    except Exception as e:
        session.rollback()
        print(f"Error committing notification: {e}")
    finally:
        session.close()