from datetime import datetime
from enum import Enum, unique
from typing import Annotated, Optional, TypeVar
import uuid

from fastapi import File, UploadFile
from pydantic import HttpUrl

from schemas.base import BaseProps
from schemas.enumschema import (
    CheckoutTypeSchema,
    PaymentTypeSchema,
    StripePaymentStatusSchema,
    UserRoleSchema,
)


@unique
class PaymentStatusSchema(str, Enum):
    ACCEPTED = "accepted"
    PENDING = "pending"
    DECLINED = "declined"

    def __str__(self):
        return super().__str__()


class PaymentMethodDetails(BaseProps):
    type: str
    card_brand: Optional[str] = None
    last_four_digits: Optional[str] = None


class PaymentBaseSchema(BaseProps):
    amount: Optional[float] = None
    bank: Optional[str] = None
    transaction_id: Optional[str] = None
    transaction_date: Optional[datetime] = None
    user_profile_id: Optional[int] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=PaymentBaseSchema)


class PaymentCreateSchema(PaymentBaseSchema):
    status: PaymentStatusSchema = PaymentStatusSchema.PENDING


class PaymentReadSchema(PaymentBaseSchema):
    id: int
    transaction_screenshot_path: str
    status: PaymentStatusSchema


class StripePaymentReadSchema(BaseProps):
    id: str
    amount: int
    currency: str
    description: Optional[str] = None
    created: int
    status: StripePaymentStatusSchema
    paid: Optional[bool]
    refunded: Optional[bool]
    receipt_url: Optional[HttpUrl] = None
    payment_method_details: Optional[PaymentMethodDetails] = None


class PaymentSearchSchema(BaseProps):
    transaction_id: Optional[str] = None


class PaymentFilterSchema(BaseProps):
    id: Optional[int] = None
    user_profile_id: Optional[int] = None
    bank: Optional[str] = None
    status: Optional[PaymentStatusSchema] = None


class StripePaymentFilterSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    role: Optional[UserRoleSchema] = None
    activity_type: Optional[CheckoutTypeSchema] = None
