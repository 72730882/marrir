from typing import Generic, TypeVar, Optional

from pydantic import BaseModel, Extra
from typing import Generic, TypeVar, List, Optional
from pydantic import BaseModel
from pydantic.generics import GenericModel


M = TypeVar("M", bound=BaseModel)


class BaseProps(BaseModel):
    class Config:
        from_attributes = True
        extra = Extra.forbid


class BaseGenericResponse(BaseModel):
    error: Optional[bool]
    message: Optional[str]
    status_code: Optional[int]
    count: Optional[int] = None


T = TypeVar("T")

class GenericSingleResponse(BaseGenericResponse, Generic[M]):
    data: Optional[M]
    dealer: Optional[list] = None
    selectable: Optional[list] = None


class GenericMultipleResponse(BaseGenericResponse, Generic[M]):
    data: list[M]
