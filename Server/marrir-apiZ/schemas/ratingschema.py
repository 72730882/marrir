from enum import Enum, unique
import importlib
from typing import Optional, TypeVar
import uuid

from schemas.base import BaseProps
from schemas.enumschema import RatingTypeSchema

class RatingBaseSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    value: Optional[float] = None
    description: Optional[str] = None
    rated_by: Optional[uuid.UUID] = None
    type: Optional[RatingTypeSchema] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=RatingBaseSchema)


class RatingCreateSchema(RatingBaseSchema):
    pass


class RatingReadSchema(RatingBaseSchema):
    id: int
    rated_by: uuid.UUID
    type: RatingTypeSchema


class UserRatingSchema(BaseProps):
    admin_rating: float
    self_rating: float
    sponsor_rating: float

class EmployeeRatingFilterSchema(BaseProps):
    manager_id: Optional[uuid.UUID] = None

class RatingFilterSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    email: Optional[str] = None
    rated_by: Optional[uuid.UUID] = None
    type: Optional[RatingTypeSchema] = None


class RatingUpdatePayload(BaseProps):
    value: Optional[float] = None
    description: Optional[str] = None


class RatingUpdateSchema(BaseProps):
    filter: RatingFilterSchema
    update: RatingUpdatePayload
