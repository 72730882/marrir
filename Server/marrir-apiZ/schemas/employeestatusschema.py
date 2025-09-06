from datetime import datetime
from enum import Enum, unique
from typing import List, Optional, TypeVar
import uuid

from schemas.base import BaseProps
from schemas.enumschema import EmployeeStatusTypeSchema


class EmployeeStatusBaseSchema(BaseProps):
    user_id: Optional[uuid.UUID]
    status: Optional[EmployeeStatusTypeSchema] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=EmployeeStatusBaseSchema)


class EmployeeStatusCreateSchema(EmployeeStatusBaseSchema):
    user_id: uuid.UUID
    status: EmployeeStatusTypeSchema
    reason: Optional[str]


class EmployeeStatusReadSchema(EmployeeStatusBaseSchema):
    id: Optional[int]
    reason: Optional[str]
    created_at: datetime
    updated_at: Optional[datetime]


class EmployeeStatusFilterSchema(BaseProps):
    id: Optional[int] = None
    user_id: Optional[uuid.UUID] = None


class EmployeeStatusUpdatePayload(BaseProps):
    status: Optional[EmployeeStatusTypeSchema] = None
    reason: Optional[str] = None

class EmployeeStatusUpdateSchema(BaseProps):
    filter: EmployeeStatusFilterSchema
    update: EmployeeStatusUpdatePayload


class EmployeeStatusDeleteSchema(BaseProps):
    id: int
