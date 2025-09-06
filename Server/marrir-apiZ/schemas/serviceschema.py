from datetime import datetime
from enum import Enum, unique
from typing import List, Optional, TypeVar

from schemas.base import BaseProps
from schemas.checkoutschema import CheckoutTypeSchema


class ServiceBaseSchema(BaseProps):
    name: Optional[str] = None
    description: Optional[str] = None
    amount: Optional[float] = None
    recurring: Optional[bool] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=ServiceBaseSchema)


class ServiceCreateSchema(ServiceBaseSchema):
    pass

class ServiceReadSchema(ServiceBaseSchema):
    id: int

class ServicePriceReadSchema(ServiceBaseSchema):
    id: int
    active: bool
    created_at: datetime
    currency: Optional[str] = None
    description: Optional[str] = None
    features: List[str] = []
    images: List[str] = []
    name: str
    type: str
    unit_label: Optional[str] = None
    updated_at: datetime
    url: Optional[str] = None


class ServiceFilterSchema(BaseProps):
    id: Optional[int] = None
    name: Optional[str] = None


class ServiceUpdatePayload(ServiceBaseSchema):
    pass


class ServiceUpdateSchema(BaseProps):
    filter: ServiceFilterSchema
    update: ServiceUpdatePayload
