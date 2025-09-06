from enum import Enum, unique
import json
from typing import Any, List, Optional, TypeVar
import uuid

from pydantic import Field

from schemas.base import BaseProps
from schemas.enumschema import (
    LanguageProficiencySchema,
    MaritalStatusSchema,
    ReligionSchema,
    SexSchema,
    SkinToneSchema,
)


class WorkExperienceCreateSchema(BaseProps):
    company_name: Optional[str] = None
    country: Optional[str] = None
    city: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None


class ReferenceCreateSchema(BaseProps):
    name: Optional[str] = None
    phone_number: Optional[str] = None
    email: Optional[str] = None
    birth_date: Optional[str] = None
    gender: Optional[str] = None
    country: Optional[str] = None
    city: Optional[str] = None
    sub_city: Optional[str] = None
    zone: Optional[str] = None
    house_no: Optional[str] = None
    po_box: Optional[int] = None


class CVBaseSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    national_id: Optional[str] = None
    passport_number: Optional[str] = None
    nationality: Optional[str] = None
    amharic_full_name: Optional[str] = None
    arabic_full_name: Optional[str] = None
    english_full_name: Optional[str] = None
    sex: Optional[SexSchema] = None
    email: Optional[str] = None
    phone_number: Optional[str] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    skin_tone: Optional[SkinToneSchema] = None
    date_of_birth: Optional[str] = None
    place_of_birth: Optional[str] = None
    religion: Optional[ReligionSchema] = None
    marital_status: Optional[MaritalStatusSchema] = None
    number_of_children: Optional[int] = None
    occupation_category: Optional[str] = None
    occupation: Optional[str] = None
    amharic: Optional[LanguageProficiencySchema] = None
    arabic: Optional[LanguageProficiencySchema] = None
    english: Optional[LanguageProficiencySchema] = None
    intro_video: Optional[str] = None
    head_photo: Optional[str] = None
    full_body_photo: Optional[str] = None
    remove_intro_video: Optional[bool] = False
    remove_head_photo: Optional[bool] = False
    remove_full_body_photo: Optional[bool] = False
    summary: Optional[str] = None
    passport_url: Optional[str] = None
    expected_salary: Optional[str] = None
    currency: Optional[str] = None
    facebook: Optional[str] = None
    x: Optional[str] = None
    instagram: Optional[str] = None
    telegram: Optional[str] = None
    tiktok: Optional[str] = None
    skills_one: Optional[str] = None
    skills_two: Optional[str] = None
    skills_three: Optional[str] = None
    skills_four: Optional[str] = None
    skills_five: Optional[str] = None
    skills_six: Optional[str] = None
    date_issued: Optional[str] = None
    place_issued: Optional[str] = None
    date_of_expiry: Optional[str] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=CVBaseSchema)


class EducationData(BaseProps):
    highest_level: Optional[str] = None
    institution_name: Optional[str] = None
    country: Optional[str] = None
    city: Optional[str] = None
    grade: Optional[str] = None


class AddressData(BaseProps):
    country: Optional[str] = None
    region: Optional[str] = None
    city: Optional[str] = None
    house_no: Optional[str] = None
    po_box: Optional[int] = None
    zip_code: Optional[str] = None
    street: Optional[str] = None
    street2: Optional[str] = None
    street3: Optional[str] = None


class AdditionalLanguageData(BaseProps):
    language: Optional[str] = None
    proficiency: Optional[LanguageProficiencySchema] = None


class AdditionalLanguageCreateSchema(AdditionalLanguageData):
    cv_id: int


class AdditionalLanguageReadSchema(AdditionalLanguageData):
    id: Optional[int] = None
    cv_id: Optional[int] = None


class CVProgressSchema(BaseProps):
    id_progress: Optional[float]
    personal_info_progress: Optional[float]
    address_progress: Optional[float]
    education_progress: Optional[float]
    photo_and_language_progress: Optional[float]
    experience_progress: Optional[float]
    reference_progress: Optional[float]
    contact_progress: Optional[float]


class CVUpsertSchema(CVBaseSchema):
    address: Optional[AddressData] = None
    education: Optional[EducationData] = None
    work_experiences: List[WorkExperienceCreateSchema] = []
    references: List[ReferenceCreateSchema] = []


class CVReadSchema(CVBaseSchema):
    id: int
    address_id: Optional[int] = None
    address: Optional[AddressData] = None
    additional_languages: List[AdditionalLanguageData] = []
    education: Optional[EducationData] = None
    work_experiences: List[WorkExperienceCreateSchema] = []
    references: List[ReferenceCreateSchema] = []
    summary: Optional[str] = None
    passport_url: Optional[str] = None

    

    class Config:
        orm_mode = True

class RedactedCVReadSchema(BaseProps):
    id: int
    nationality: Optional[str] = None
    amharic_full_name: Optional[str] = None
    arabic_full_name: Optional[str] = None
    english_full_name: Optional[str] = None
    sex: Optional[SexSchema] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    skin_tone: Optional[SkinToneSchema] = None
    date_of_birth: Optional[str] = None
    place_of_birth: Optional[str] = None
    religion: Optional[ReligionSchema] = None
    marital_status: Optional[MaritalStatusSchema] = None
    number_of_children: Optional[int] = None
    occupation_category: Optional[str] = None
    occupation: Optional[str] = None
    amharic: Optional[LanguageProficiencySchema] = None
    arabic: Optional[LanguageProficiencySchema] = None
    english: Optional[LanguageProficiencySchema] = None
    intro_video: Optional[str] = None
    head_photo: Optional[str] = None
    full_body_photo: Optional[str] = None
    additional_languages: List[AdditionalLanguageData] = []
    summary: Optional[str] = None
    expected_salary: Optional[str] = None
    passport_url: Optional[str] = None

class CVDeleteSchema(CVBaseSchema):
    pass


class CVFilterSchema(BaseProps):
    id: Optional[int] = None
    user_id: Optional[uuid.UUID] = None
    email: Optional[str] = None
    passport_number: Optional[str] = None


class CVSearchSchema(BaseProps):
    english_full_name: Optional[str] = Field(None)
    amharic_full_name: Optional[str] = Field(None)
    arabic_full_name: Optional[str] = Field(None)
    email: Optional[str] = Field(None)
    phone_number: Optional[str] = Field(None)
    passport_number: Optional[str] = Field(None)
