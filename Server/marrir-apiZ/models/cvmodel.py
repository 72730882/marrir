import uuid
from sqlalchemy import VARCHAR, Float, ForeignKey, Integer, String, Unicode
from sqlalchemy.orm import Mapped, mapped_column, relationship
from schemas.cvschema import (
    LanguageProficiencySchema,
    MaritalStatusSchema,
    SexSchema,
    SkinToneSchema,
)
from .base import EntityBaseModel
from .db import Base


class CVModel(Base, EntityBaseModel):
    __tablename__ = "table_cvs"
    passport_number: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=True
    )
    id = mapped_column(Integer, primary_key=True, unique=True)    
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), unique=True, nullable=True
    )
    summary: Mapped[str] = mapped_column(String, nullable=True)
    email: Mapped[str] = mapped_column(String(255), nullable=True)
    national_id: Mapped[str] = mapped_column(String(255), nullable=True)
    amharic_full_name: Mapped[str] = mapped_column(String(255), nullable=True)
    arabic_full_name: Mapped[str] = mapped_column(String(255), nullable=True)
    english_full_name: Mapped[str] = mapped_column(String(255), nullable=True)
    sex: Mapped[str] = mapped_column(String(255), nullable=True)
    phone_number: Mapped[str] = mapped_column(String(255), nullable=True)
    height: Mapped[float] = mapped_column(Float, nullable=True)
    weight: Mapped[float] = mapped_column(Float, nullable=True)
    skin_tone: Mapped[str] = mapped_column(String(255), nullable=True)
    date_of_birth: Mapped[str] = mapped_column(String(255), nullable=True)
    place_of_birth: Mapped[str] = mapped_column(String(255), nullable=True)
    nationality: Mapped[str] = mapped_column(String(255), nullable=True)
    religion: Mapped[str] = mapped_column(String(255), nullable=True)
    marital_status: Mapped[str] = mapped_column(String(255), nullable=True)
    number_of_children: Mapped[int] = mapped_column(Integer, nullable=True)
    occupation_category: Mapped[str] = mapped_column(String(255), nullable=True)
    occupation: Mapped[str] = mapped_column(String(255), nullable=True)
    amharic: Mapped[str] = mapped_column(String(255), nullable=True)
    arabic: Mapped[str] = mapped_column(String(255), nullable=True)
    english: Mapped[str] = mapped_column(String(255), nullable=True)
    intro_video: Mapped[str] = mapped_column(String(255), nullable=True)
    head_photo: Mapped[str] = mapped_column(String(255), nullable=True)
    full_body_photo: Mapped[str] = mapped_column(String(255), nullable=True)
    facebook: Mapped[str] = mapped_column(String(255), nullable=True)
    x: Mapped[str] = mapped_column(String(255), nullable=True)
    telegram: Mapped[str] = mapped_column(String(255), nullable=True)
    tiktok: Mapped[str] = mapped_column(String(255), nullable=True)
    instagram: Mapped[str] = mapped_column(String(255), nullable=True)
    address_id: Mapped[int] = mapped_column(
        ForeignKey("table_addresses.id"), nullable=True
    )
    additional_languages = relationship(
        "AdditionalLanguageModel", back_populates="cv", cascade="all, delete"
    )
    address = relationship(
        "AddressModel",
        back_populates="cv",
        uselist=False,
        cascade="all, delete",
        lazy="select",
    )
    work_experiences = relationship(
        "WorkExperienceModel",
        cascade="all, delete",
        back_populates="cv",
    )
    references = relationship(
        "ReferenceModel",
        cascade="all, delete",
        back_populates="cv",
    )
    education = relationship(
        "EducationModel",
        back_populates="cv",
        uselist=False,
        cascade="all, delete",
        lazy="select",
    )
    expected_salary: Mapped[float] = mapped_column(String, nullable=True)
    currency: Mapped[float] = mapped_column(String, nullable=True)
    passport_number: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=True
    )
    date_issued: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=True
    )
    place_issued: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=True
    )
    date_of_expiry: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=True
    )
    
    skills_one: Mapped[float] = mapped_column(String, nullable=True)
    skills_two: Mapped[float] = mapped_column(String, nullable=True)
    skills_three: Mapped[float] = mapped_column(String, nullable=True)
    skills_four: Mapped[float] = mapped_column(String, nullable=True)
    skills_five: Mapped[float] = mapped_column(String, nullable=True)
    skills_six: Mapped[float] = mapped_column(String, nullable=True)
    passport_url: Mapped[str] = mapped_column(String, nullable=True)
















    