from enum import Enum, unique
from typing import List, Optional, TypeVar

from schemas.base import BaseProps
from schemas.enumschema import OccupationTypeSchema


class OccupationBaseSchema(BaseProps):
    # name: Optional[OccupationTypeSchema] = None
    name: Optional[str] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=OccupationBaseSchema)


class OccupationCategoryCreateSchema(BaseProps):
    name: str

class OccupationCreateSchema(OccupationBaseSchema):
    name: str
    category_id: int
    
# class OccupationCreateSchema(OccupationBaseSchema):
#     name: OccupationTypeSchema

class OccupationCategoryReadSchema(BaseProps):
    id: int
    name: str
    occupations: List[OccupationBaseSchema] = None

class OccupationReadSchema(OccupationBaseSchema):
    id: int
    name: str
    category_id: int

# class OccupationReadSchema(OccupationBaseSchema):
#     id: int
#     name: OccupationTypeSchema


class OccupationFilterSchema(BaseProps):
    id: Optional[int] = None


# class OccupationUpdatePayload(OccupationBaseSchema):
#     name: Optional[OccupationTypeSchema] = None

class OccupationCategoryUpdatePayload(BaseProps):
    name: Optional[str] = None

class OccupationCategoryUpdateSchema(BaseProps):
    filter: OccupationFilterSchema
    update: OccupationCategoryUpdatePayload


class OccupationUpdateSchema(BaseProps):
    filter: OccupationFilterSchema
    update: OccupationCategoryUpdatePayload

# class OccupationDeleteSchema(OccupationBaseSchema):
#     id: Optional[int] = None
#     name: Optional[OccupationTypeSchema] = None
class OccupationDeleteSchema(OccupationBaseSchema):
    id: Optional[int] = None
    name: Optional[str] = None
