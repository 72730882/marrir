from datetime import datetime
from enum import Enum, unique
from typing import Annotated, Any, List, Optional, TypeVar

from fastapi import File, UploadFile

from schemas.base import BaseProps
from schemas.enumschema import CheckoutTypeSchema

class CheckoutBaseSchema(BaseProps):
    service_id: Optional[int] = None
    quantity: Optional[int] = 1
    success_url: Optional[str] = None
    cancel_url: Optional[str] = None
    metadata: Optional[Any] = None


class CheckoutMetadataBaseSchema(BaseProps):
    activity_type: CheckoutTypeSchema


class TransferPaymentMetadataSchema(CheckoutMetadataBaseSchema):
    batch_transfer_id: Optional[int] = None
    transfer_ids: List[int] = []

EntityBaseSchema = TypeVar("EntityBaseSchema", bound=CheckoutBaseSchema)

class CheckoutCreateSchema(CheckoutBaseSchema):
    pass
