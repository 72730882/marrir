from enum import Enum, unique
from typing import Optional, TypeVar
import uuid

from schemas.base import BaseProps
from schemas.enumschema import OfferTypeSchema


class OfferBaseSchema(BaseProps):
    receiver_id: Optional[uuid.UUID] = None
    detail: Optional[str] = None
    job_id: Optional[int] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=OfferBaseSchema)


class OfferCreateSchema(OfferBaseSchema):
    receiver_id: uuid.UUID
    sponsor_id: Optional[uuid.UUID] = None
    job_id: int
    detail: str
    offer_status: str = OfferTypeSchema.PENDING


class OfferReadSchema(OfferBaseSchema):
    id: int
    sponsor_id: uuid.UUID
    offer_status: OfferTypeSchema


class OfferFilterSchema(BaseProps):
    id: Optional[int] = None
    receiver_id: Optional[uuid.UUID] = None
    sponsor_id: Optional[uuid.UUID] = None
    detail: Optional[str] = None
    job_id: Optional[int] = None
    offer_status: Optional[OfferTypeSchema] = None


class OfferUpdatePayload(OfferBaseSchema):
    offer_status: OfferTypeSchema


class OfferUpdateSchema(BaseProps):
    filter: OfferFilterSchema
    update: OfferUpdatePayload
