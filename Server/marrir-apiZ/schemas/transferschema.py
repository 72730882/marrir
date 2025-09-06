from datetime import datetime
from enum import Enum, unique
from typing import List, Optional, TypeVar, Literal
import uuid

from pydantic import BaseModel

from schemas.base import BaseProps
from schemas.enumschema import TransferStatusSchema
from schemas.userschema import UserReadSchema


transfer_status = Literal["accepted", "declined"]

class TransferBaseSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    user: Optional[UserReadSchema] = None
    manager_id: Optional[uuid.UUID] = None
    manager: Optional[UserReadSchema] = None


class TransferRequestBaseSchema(BaseProps):
    user_ids: List[uuid.UUID] = []
    transfer_receiver_id: uuid.UUID
    reason: Optional[str] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=TransferBaseSchema)


class TransferCreateSchema(TransferBaseSchema):
    pass


class TransferRequestCreateSchema(BaseProps):
    user_id: uuid.UUID
    requester_id: uuid.UUID
    manager_id: uuid.UUID
    batch_id: Optional[int] = None
    status: TransferStatusSchema = TransferStatusSchema.PENDING


class AllTransfersReadSchema(TransferBaseSchema):
    id: int
    previous_manager_id: Optional[uuid.UUID] = None
    previous_manager: Optional[UserReadSchema] = None


class TransferReadSchema(TransferBaseSchema):
    id: int


class TransferRequestReadSchema(BaseProps):
    id: int
    batch_id: int
    user_id: uuid.UUID
    manager_id: uuid.UUID
    requester_id: uuid.UUID
    user: Optional[UserReadSchema] = None
    manager: Optional[UserReadSchema] = None
    requester: Optional[UserReadSchema] = None
    status: str
    reason: Optional[str] = None


class BatchTransferReadSchema(BaseProps):
    id: int
    receiver_id: uuid.UUID
    receiver: UserReadSchema
    requester_id: uuid.UUID
    requester: UserReadSchema
    transfers: List[TransferRequestReadSchema] = []
    created_at: datetime
    relationship: bool = False

class TransferFilterSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    manager_id: Optional[uuid.UUID] = None


class BatchTransferFilterSchema(BaseProps):
    requester_id: Optional[uuid.UUID] = None
    receiver_id: Optional[uuid.UUID] = None


class TransferRequestFilterSchema(BaseProps):
    id: int

class MultipleTransferRequestFilterSchema(BaseProps):
    ids: List[int] = []

class TransferUpdatePayload(TransferBaseSchema):
    status: TransferStatusSchema
    reason: Optional[str] = None

class TransferUpdateSchema(BaseProps):
    filter: TransferFilterSchema
    update: TransferUpdatePayload


class TransferRequestUpdateSchema(BaseProps):
    filter: MultipleTransferRequestFilterSchema
    update: TransferUpdatePayload


class TransferRequest(BaseModel):
    receiver_id: str
    
    user_ids: List[str] = []

    reason: Optional[str] = None

class TransferRequestStatusSchema(BaseModel):
    status: transfer_status = "accepted"

    transfer_request_id: list[int]

    reason: Optional[str] = None

class TransferRequestPaymentSchema(BaseModel):
    transfer_request_ids: list[int] = []

class TransferRequestPaymentCallback(BaseModel):
    ref: str

class TransferRequestReturn(BaseModel):
    id: uuid.UUID


TransferReadSchema.model_rebuild()
