from datetime import datetime
from enum import Enum, unique
from typing import Annotated, Optional, TypeVar
import uuid

from fastapi import File, UploadFile

from schemas.base import BaseProps


class InvoiceBaseSchema(BaseProps):
    amount: Optional[float] = None
    stripe_session_id: Optional[str] = None
    customer_id: Optional[uuid.UUID] = None
    
EntityBaseSchema = TypeVar("EntityBaseSchema", bound=InvoiceBaseSchema)

class InvoiceCreateSchema(InvoiceBaseSchema):
    pass

class InvoiceReadSchema(InvoiceBaseSchema):
    id: int
