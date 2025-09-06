from datetime import datetime
from enum import Enum, unique
import enum
from typing import Annotated, List, Optional, TypeVar
import uuid

from fastapi import File, UploadFile

from schemas.base import BaseProps
from schemas.enumschema import PromotionPackageTypeSchema
from schemas.userschema import UserReadSchema

from pydantic import BaseModel

class CategoryEnum(enum.Enum):
    promotion = "promotion"
    transfer = "transfer"
    reservation = "reservation"
    employee = "employee_process"
    job_application = 'job_application'

class RoleEnum(enum.Enum):
    employee = "employee"
    agent = "agent"
    recruitment= "recruitment"
    sponsor = "sponsor"

class DurationEnum(enum.Enum):
    ONE_MONTH = "1 month"

    THREE_MONTHS = "3 months"

    SIX_MONTHS = "6 months"

    TWELVE_MONTHS = "12 months"


@unique
class PromotionStatusSchema(str, Enum):
    ACTIVE = "active"
    EXPIRED = "expired"
    CANCELLED = "cancelled"

    def __str__(self):
        return super().__str__()


class PromotionBaseSchema(BaseProps):
    package: Optional[PromotionPackageTypeSchema] = None
    status: Optional[PromotionStatusSchema] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=PromotionBaseSchema)


class PromotionCreateSchema(PromotionBaseSchema):
    user_ids: List[uuid.UUID]
    package: PromotionPackageTypeSchema


class SinglePromotionCreateSchema(PromotionBaseSchema):
    user_id: uuid.UUID
    package: PromotionPackageTypeSchema


class PromotionReadSchema(PromotionBaseSchema):
    id: int
    user_id: uuid.UUID
    user: UserReadSchema


class MultiplePromotionReadSchema(PromotionBaseSchema):
    id: int
    user_ids: List[uuid.UUID]


class PromotionFilterSchema(BaseProps):
    id: Optional[int] = None
    user_id: Optional[uuid.UUID] = None
    package: Optional[PromotionPackageTypeSchema] = None


class PromotionPackageCreateSchema(BaseModel):
    category: CategoryEnum

    role: RoleEnum

    duration: DurationEnum | None = None

    profile_count: int | None = None

    price: float


class PromotionPackageUpdateSchema(BaseModel):
    id : int
    category: CategoryEnum | None = None
    role: RoleEnum | None = None
    duration: DurationEnum | None = None
    profile_count: int | None = None
    price: float | None = None

class BuyPromotionPackage(BaseModel):
    id: int


class PromotionCreate(BaseModel):
    user_ids: list[uuid.UUID]
