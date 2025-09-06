from enum import Enum, unique
from typing import Optional, TypeVar

from schemas.base import BaseProps



class RefundBaseSchema(BaseProps):
    payment_id: Optional[int] = None

EntityBaseSchema = TypeVar("EntityBaseSchema", bound=RefundBaseSchema)


class RefundCreateSchema(RefundBaseSchema):
    reason: Optional[str] = None

class RefundReadSchema(RefundBaseSchema):
    id: int
    status: Optional[str] = None
    reason: Optional[str] = None


class RefundFilterSchema(BaseProps):
    refund_id: Optional[int] = None
    user_profile_id: Optional[int] = None

class RefundUpdatePayload(BaseProps):
    status: str

class RefundReviewSchema(BaseProps):
    filter: RefundFilterSchema
    update: RefundUpdatePayload
