from datetime import datetime
from enum import Enum, unique
from typing import Optional, Dict
from typing import TypeVar, List, Any
import uuid
from fastapi.responses import StreamingResponse

from pydantic import EmailStr, Extra, Field, model_validator
from pydantic_extra_types.phone_numbers import PhoneNumber

from custom_types.custom_types import Password
from schemas.base import BaseProps
from schemas.companyinfoschema import CompanyInfoBaseSchema
from schemas.cvschema import (
    CVReadSchema,
    EducationData,
    MaritalStatusSchema,
    RedactedCVReadSchema,
    ReligionSchema,
    SexSchema,
    SkinToneSchema,
    WorkExperienceCreateSchema,
)
from schemas.enumschema import EducationStatusSchema, EmployeeStatusTypeSchema, UserRoleSchema
from schemas.notificationschema import (
    SeenNotificationBaseSchema,
    UserNotificationBaseSchema,
)
from schemas.occupationSchema import OccupationTypeSchema
from schemas.offerschema import OfferTypeSchema
from schemas.processschema import ProcessReadSchema
from schemas.ratingschema import RatingReadSchema, UserRatingSchema
from schemas.userprofileschema import UserProfileBaseSchema


# Shared properties
class UserBaseSchema(BaseProps):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone_number: Optional[PhoneNumber] = None
    country: Optional[str] = None
    role: Optional[UserRoleSchema] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=UserBaseSchema)


def __from_orm_to_schema(schema_dict: Dict, model_dict: Dict):
    schema_keys: List[str] = list(schema_dict)
    ret_schema = dict()
    for key in schema_keys:
        ret_schema[key] = model_dict.get(key)
    return ret_schema


# User Create Schema
class UserCreateSchema(UserBaseSchema):
    password: Password


class UserReadSchema(UserBaseSchema):
    id: Optional[uuid.UUID]
    first_name: Optional[str]
    last_name: Optional[str]
    email: Optional[EmailStr]
    country: Optional[str] = None
    phone_number: Optional[PhoneNumber]
    role: UserRoleSchema
    cv: Optional[CVReadSchema]
    disabled: Optional[bool] = False
    status: Optional[EmployeeStatusTypeSchema] = None
    process: Optional[ProcessReadSchema]
    profile: Optional[UserProfileBaseSchema]
    company: Optional[CompanyInfoBaseSchema]
    notification_reads: List[SeenNotificationBaseSchema] = []
    user_notifications: List[UserNotificationBaseSchema] = []
    verified: bool
    created_at: datetime

    class Config:
        from_attributes = True


class EmployeeRatingSchema(BaseProps):
    user_id: uuid.UUID
    user_name: Optional[str] = None
    user: Optional[CVReadSchema] = None
    ratings: UserRatingSchema


class EmployeeReadSchema(BaseProps):
    id: Optional[uuid.UUID]
    first_name: Optional[str]
    last_name: Optional[str]
    email: Optional[EmailStr]
    cv: Optional[CVReadSchema] = None
    process: Optional[ProcessReadSchema] = None
    rating: Optional[UserRatingSchema] = None
    disabled: Optional[bool] = False
    education: Optional[EducationData] = None
    work_experiences: List[WorkExperienceCreateSchema] = []
    cv_completed: Optional[bool]

class RedactedEmployeeReadSchema(BaseProps):
    id: Optional[uuid.UUID]
    first_name: Optional[str]
    last_name: Optional[str]
    cv: Optional[RedactedCVReadSchema] = None
    rating: Optional[UserRatingSchema] = None
    disabled: Optional[bool] = False
    education: Optional[EducationData] = None
    work_experiences: List[WorkExperienceCreateSchema] = []

class UsersFilterSchema(BaseProps):
    id: Optional[uuid.UUID] = Field(None)
    first_name: Optional[str] = Field(None)
    last_name: Optional[str] = Field(None)
    email: Optional[EmailStr] = Field(None)
    phone_number: Optional[PhoneNumber] = Field(None)
    country: Optional[str] = Field(None)
    role: Optional[UserRoleSchema] = Field(None)
    disabled: Optional[bool] = Field(None)

class UsersSearchSchema(BaseProps):
    first_name: Optional[str] = Field(None)
    last_name: Optional[str] = Field(None)
    email: Optional[EmailStr] = Field(None)
    country: Optional[str] = Field(None)
    phone_number: Optional[PhoneNumber] = Field(None)


class AdminUsersSearchSchema(UsersSearchSchema):
    company_name: Optional[str] = Field(None)
    location: Optional[str] = Field(None)
    
class UserFilterSchema(BaseProps):
    id: Optional[uuid.UUID] = Field(None)
    email: Optional[EmailStr] = Field(None)
    phone_number: Optional[PhoneNumber] = Field(None)

    @model_validator(mode="before")
    def check_fields(self, data: Any) -> Any:
        id = self.get("id")
        email = self.get("email")
        phone_number = self.get("phone_number")
        if email is not None and phone_number is not None:
            raise ValueError(f"two filter fields can not be provided")
        if email is None and phone_number is None and id is None:
            raise ValueError("no filter fields provided")
        return self


class UserLoginSchema(BaseProps):
    email: Optional[EmailStr] = Field(None)
    phone_number: Optional[PhoneNumber] = Field(None)
    password: str

    @model_validator(mode="before")
    def check_fields(self, data: Any) -> Any:
        email = self.get("email")
        phone_number = self.get("phone_number")
        if email is not None and phone_number is not None:
            raise ValueError(f"two filter fields can not be provided")
        if email is None and phone_number is None:
            raise ValueError("no filter fields provided")
        return self


class UserCVFilterSchema(BaseProps):
    min_height: Optional[int] = 0
    max_height: Optional[int] = None
    min_weight: Optional[int] = 0
    max_weight: Optional[int] = None
    min_age: Optional[int] = None
    max_age: Optional[int] = None
    sex: Optional[SexSchema] = None
    nationality: Optional[str] = None
    religion: Optional[ReligionSchema] = None
    occupation: Optional[OccupationTypeSchema] = None
    marital_status: Optional[MaritalStatusSchema] = None
    education_status: Optional[EducationStatusSchema] = None
    skin_tone: Optional[SkinToneSchema] = None


class UserUpdatePayload(UserBaseSchema):
    password: Optional[Password] = None


# User Update Schema
class UserUpdateSchema(BaseProps):
    filter: UserFilterSchema
    update: UserUpdatePayload


class UserDeleteSchema(UserBaseSchema):
    id: Optional[int] = None
    email: Optional[EmailStr] = None
    phone_number: Optional[PhoneNumber] = None


class UserTokenSchema(BaseProps):
    id: uuid.UUID
    email: Optional[EmailStr] = None
    phone_number: Optional[PhoneNumber] = None
    role: UserRoleSchema

    def as_dict(self):
        return {
            "id": str(self.id),
            "email": self.email,
            "role": str(self.role),
        }


class UserTokenResponseSchema(BaseProps):
    user_id: uuid.UUID
    access_token: str
    refresh_token: str
    email: str
    role: str


class UserProfileViewSchema(BaseProps):
    user_id: uuid.UUID
    profile_viewer_id: uuid.UUID


class EmailRequest(BaseProps):
    email: EmailStr


class OTPRequest(BaseProps):
    email: EmailStr
    otp: str


class PasswordResetRequest(BaseProps):
    email: EmailStr
    otp: str
    new_password: str
    confirm_password: str


class UploadTermsRequest(BaseProps):
    email: EmailStr
    terms_file_path: str
   
