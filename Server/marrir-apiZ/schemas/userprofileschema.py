from enum import Enum, unique
from typing import Optional, Dict
from typing import TypeVar, List, Any

from schemas.base import BaseProps
from schemas.paymentschema import PaymentBaseSchema

from schemas.refundschema import RefundBaseSchema

# Shared properties
class UserProfileBaseSchema(BaseProps):
    id: Optional[int] = None
    # refunds: Optional[List[RefundBaseSchema]] = None
    payments: Optional[List[PaymentBaseSchema]] = None 

EntityBaseSchema = TypeVar("EntityBaseSchema", bound=UserProfileBaseSchema)
