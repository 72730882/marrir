from datetime import datetime
from typing import List, Optional, TypeVar, Literal
import uuid

from pydantic import BaseModel

from schemas.base import BaseProps
from schemas.cvschema import CVReadSchema, LanguageProficiencySchema
from schemas.enumschema import EducationStatusSchema, TransferStatusSchema
from schemas.userschema import UserReadSchema

recruitment_reserve_status = Literal["accepted", "declined"]

class ReserveBaseSchema(BaseProps):
    reserver_id: Optional[uuid.UUID] = None
    status: Optional[TransferStatusSchema] = None
    reason: Optional[str] = None

EntityBaseSchema = TypeVar("EntityBaseSchema", bound=ReserveBaseSchema)


class ReserveCreateSchema(ReserveBaseSchema):
    cv_id: List[int]
    reserver_id: uuid.UUID


class ReserveSingleCreateSchema(ReserveBaseSchema):
    cv_id: int
    reserver_id: uuid.UUID


class ReserveReadMultipleSchema(ReserveBaseSchema):
    id: int
    cv_id: List[int]
    cv: CVReadSchema
    reserver: UserReadSchema


class ReserveReadSchema(ReserveBaseSchema):
    id: int
    cv_id: int
    cv: CVReadSchema
    reserver: UserReadSchema
    created_at: datetime


class ReserveFilterSchema(BaseProps):
    cv_id: Optional[int] = None
    reserver_id: Optional[uuid.UUID] = None
    
class MultipleReserveFilterSchema(BaseProps):
    cv_ids: List[int] = []
    batch_id: int

class BatchReserveReadSchema(BaseProps):
    id: int
    reserver_id: uuid.UUID
    reserver: UserReadSchema
    created_at: datetime
    reserves: List[ReserveReadSchema] = []


class ReserveCVFilterSchema(BaseProps):
    # user_id: Optional[uuid.UUID] = None
    cv_id: Optional[int] = None
    reserver_id: Optional[uuid.UUID] = None
    sex: Optional[str] = None
    skin_tone: Optional[str] = None
    marital_status: Optional[str] = None
    religion: Optional[str] = None
    nationality: List[str] = []
    occupation: List[str] = []
    education_level: Optional[EducationStatusSchema] = None
    min_height: Optional[int] = None
    max_height: Optional[int] = None
    min_weight: Optional[int] = None
    max_weight: Optional[int] = None
    min_age: Optional[int] = None
    max_age: Optional[int] = None
    english: Optional[LanguageProficiencySchema] = None
    arabic: Optional[LanguageProficiencySchema] = None
    amharic: Optional[LanguageProficiencySchema] = None
    status: Optional[TransferStatusSchema] = None


class ReserveUpdatePayload(BaseProps):
    status: TransferStatusSchema
    reason: Optional[str] = None

class ReserveUpdateSchema(BaseProps):
    filter: MultipleReserveFilterSchema
    update: ReserveUpdatePayload

class GenericMultipleResponseEmployee(BaseProps):
    status_code: int
    message: str
    error: bool
    data: List[ReserveReadSchema]
    count: int

class GenericMultipleResponseManager(BaseProps):
    status_code: int
    message: str
    error: bool
    data: List[BatchReserveReadSchema]
    count: int


class ReservationPayMeta(BaseModel):
    reserve_ids: list[int]
    batch_reserve_id: int

class ReservePay(BaseModel):
    amount: float | None = None
    id: int | None = None
    metadata: ReservationPayMeta | None = None
    method: bool | None = None
    package: str | None = None
    user_id: uuid.UUID | None = None


class RecruitmentReserveSubscriptionBuy(BaseModel):
    id: int


class RecruitmentReserveCreate(BaseModel):
    recruitment_id: uuid.UUID
    employee_id: uuid.UUID


class RecruitmentReserveStatusUpdate(BaseModel):
    status: recruitment_reserve_status = "accepted"
    id: int


class RecruitmentReserveReadSchema(BaseModel):
    id: int | None = None
    recruitment_id: uuid.UUID | None = None
    employee_id: uuid.UUID | None = None
    sponsor_id: uuid.UUID | None = None
    status: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    employee: UserReadSchema | None = None
    recruitment: UserReadSchema | None = None
    sponsor: UserReadSchema | None = None
