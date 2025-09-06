from sqlalchemy import Boolean, DateTime, Float, ForeignKey, LargeBinary, String
from sqlalchemy.dialects.postgresql import ENUM as PG_ENUM
from sqlalchemy.orm import Mapped, mapped_column, relationship

from models.base import EntityBaseModel
from models.db import Base
from schemas.paymentschema import PaymentStatusSchema, PaymentTypeSchema


class PaymentModel(Base, EntityBaseModel):
    __tablename__ = "table_payments"
    amount: Mapped[float] = mapped_column(Float())
    bank: Mapped[str] = mapped_column(String(255), nullable=False)
    transaction_id: Mapped[str] = mapped_column(String(255), nullable=False)
    transaction_date = mapped_column(DateTime, nullable=False)
    transaction_screenshot_path = mapped_column(String(255), nullable=False)
    status: Mapped[str] = mapped_column(
        String(255), default=PaymentStatusSchema.PENDING
    )
    user_profile_id: Mapped[int] = mapped_column(
        ForeignKey("table_user_profiles.id"), nullable=False
    )
    user_profile = relationship("UserProfileModel", back_populates="payments")
    # __mapper_args__ = {
    #     'polymorphic_identity': 'payment',
    #     'polymorphic_on': type
    # }


# class LocalPayment(PaymentModel):
#     __tablename__ = 'table_local_payments'
#     transaction_id: Mapped[str] = mapped_column(String(255), nullable=False)
#     transaction_date = mapped_column(DateTime, nullable=False)
#     transaction_screenshot: Mapped[str] = mapped_column(String(255), nullable=False)

#     __mapper_args__ = {
#         'polymorphic_identity': 'local_payment',
#         'inherit_condition': (PaymentModel.id == id)
#     }

# class InternationalPayment(PaymentModel):
#     __tablename__ = 'table_international_payments'
#     international_attribute = Column(String(255), nullable=True)

#     __mapper_args__ = {
#         'polymorphic_identity': 'international_payment',
#         'inherit_condition': (PaymentModel.id == id)
#     }
