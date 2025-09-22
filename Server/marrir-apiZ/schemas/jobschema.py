from datetime import datetime
from enum import Enum, unique
from typing import List, Optional, TypeVar
import uuid

from pydantic import BaseModel, EmailStr
from pydantic_extra_types.phone_numbers import PhoneNumber

from schemas.base import BaseProps
from schemas.companyinfoschema import CompanyInfoBaseSchema
from schemas.enumschema import EducationStatusSchema, JobTypeSchema, OccupationTypeSchema, OfferTypeSchema
from schemas.userschema import UserReadSchema


class ApplyJobReadSchema(BaseProps):
    id: int
    job_id: int
    user_id: uuid.UUID
    user: Optional[UserReadSchema] = None
    status: Optional[OfferTypeSchema] = OfferTypeSchema.PENDING
    is_open: Optional[bool] = None


class ApplyJobSingleBaseSchema(BaseProps):
    job_id: int
    user_id: uuid.UUID
    status: Optional[OfferTypeSchema] = OfferTypeSchema.PENDING

class ApplyJobSingleReadSchema(ApplyJobSingleBaseSchema):
    user: Optional[UserReadSchema] = None

class JobPosterSchema(BaseProps):
    id: Optional[uuid.UUID]
    first_name: Optional[str]
    last_name: Optional[str]
    email: Optional[EmailStr]
    phone_number: Optional[PhoneNumber]
    company: Optional[CompanyInfoBaseSchema]


class ApplyJobMultipleBaseSchema(BaseProps):
    job_id: int
    user_id: List[uuid.UUID] = []
    status: Optional[OfferTypeSchema] = OfferTypeSchema.PENDING


class JobBaseSchema(BaseProps):
    name: Optional[str] = None
    description: Optional[str] = None
    amount: Optional[int] = None
    location: Optional[str] = None
    occupation: Optional[OccupationTypeSchema] = None
    education_status: Optional[EducationStatusSchema] = None
    type: Optional[JobTypeSchema] = None
    posted_by: Optional[uuid.UUID] = None
    is_open: Optional[bool] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=JobBaseSchema)


class JobCreateSchema(JobBaseSchema):
    pass


class JobReadSchema(JobBaseSchema):
    id: int
    job_applications: List[ApplyJobSingleReadSchema] = []
    job_poster: Optional[JobPosterSchema] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    deleted_at: Optional[datetime] = None


class JobUpdatePayload(BaseProps):
    name: Optional[str] = None
    description: Optional[str] = None
    amount: Optional[int] = None
    location: Optional[str] = None
    occupation: Optional[OccupationTypeSchema] = None
    education_status: Optional[EducationStatusSchema] = None
    type: Optional[JobTypeSchema] = None


class JobsFilterSchema(JobBaseSchema):
    id: Optional[int] = None


class JobsSearchSchema(BaseProps):
    name: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None


class JobUpdateSchema(BaseProps):
    filter: JobsFilterSchema
    update: JobUpdatePayload


class JobApplicationDeleteSchema(ApplyJobSingleBaseSchema):
    pass


class ApplicationStatusUpdateSchema(BaseModel):
    status: OfferTypeSchema

    job_application_ids: list[int]


class JobApplicationPaymentInfoSchema(BaseModel):
    job_application_ids: list[int]
    job_id: int