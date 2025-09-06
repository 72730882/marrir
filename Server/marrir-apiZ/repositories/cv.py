from datetime import datetime
import io
import json
from operator import or_
import os
import tempfile
from typing import Any, Dict, Optional, Union, Generic, List
import uuid
from fastapi import BackgroundTasks, File, Form, Request, UploadFile
from fastapi.encoders import jsonable_encoder
from fastapi.templating import Jinja2Templates
from core.auth import RBACAccessType
from core.context_vars import context_set_response_code_message, context_actor_user_data
from fastapi.responses import FileResponse, StreamingResponse

from sqlalchemy import BinaryExpression, column
from sqlalchemy.sql.operators import like_op
from sqlalchemy.orm import Session
from models.additionallanguagemodel import AdditionalLanguageModel
from models.addressmodel import AddressModel
from models.cvmodel import CVModel
from models.educationmodel import EducationModel
from models.employeemodel import EmployeeModel
from models.referencemodel import ReferenceModel
from models.usermodel import UserModel
from models.userprofilemodel import UserProfileModel
from models.workexperiencemodel import WorkExperienceModel
import pdfkit

from repositories.base import (
    BaseRepository,
    EntityType,
    UpdateSchemaType,
    CreateSchemaType,
    FilterSchemaType,
)
from schemas.base import BaseGenericResponse
from schemas.cvschema import (
    AdditionalLanguageCreateSchema,
    AdditionalLanguageReadSchema,
    CVFilterSchema,
    CVProgressSchema,
    CVUpsertSchema,
    SexSchema,
)

import pandas as pd

from schemas.userschema import UserRoleSchema
from utils.generate_qr import generate_qr_code, my_qr_code
from utils.generatepdf import generate_report
from utils.mrz_reader import read_mrz
from utils.uploadfile import uploadFileToLocal
import logging
from core.security import settings
from io import BytesIO
# Configure logging
logger = logging.getLogger(__name__)


class CVRepository(BaseRepository[CVModel, CVUpsertSchema, CVUpsertSchema]):
    def get(self, db: Session, filters: FilterSchemaType) -> EntityType:
        return super().get(db, filters)

    def progress(self, db: Session, filters: CVFilterSchema) -> Any:
        cv = db.query(CVModel).filter_by(user_id=filters.user_id).first()
        id_fields = ["national_id", "passport_number", "nationality"]

        personal_info_fields = [
            "english_full_name",
            "amharic_full_name",
            "arabic_full_name",
            "sex",
            "email",
            "phone_number",
            "height",
            "weight",
            "marital_status",
            "number_of_children",
            "skin_tone",
            "date_of_birth",
            "place_of_birth",
            "religion",
        ]

        address_info_fields = [
            "country",
            "city",
            "region",
            "street3",
            "street2",
            "street1",
            "street",
            "zip_code",
            "house_no",
            "po_box",
        
        ]

        education_info_fields = [
            "highest_level",
            "institution_name",
            "country",
            "city",
            "grade",
        ]

        photo_and_language_info_fields = [
            "amharic",
            "arabic",
            "english",
            "head_photo",
            "full_body_photo",
            "intro_video",
        ]

        contact_info_fields = ["facebook", "x", "telegram", "tiktok"]

        (
            id_progress,
            personal_info_progress,
            address_progress,
            education_progress,
            photo_and_language_progress,
            experience_progress,
            reference_progress,
            contact_progress,
        ) = (
            (sum(getattr(cv, field) is not None for field in id_fields) if cv else 0)
            / len(id_fields)
            * 100,
            (
                sum(getattr(cv, field) is not None for field in personal_info_fields)
                if cv
                else 0
            )
            / len(personal_info_fields)
            * 100,
            (
                sum(
                    getattr(cv.address, field) is not None
                    for field in address_info_fields
                )
                if cv and cv.address
                else 0
            )
            / len(address_info_fields)
            * 100,
            (
                sum(
                    getattr(cv.education, field) is not None
                    for field in education_info_fields
                )
                if cv and cv.education
                else 0
            )
            / len(education_info_fields)
            * 100,
            (
                sum(
                    getattr(cv, field) is not None
                    for field in photo_and_language_info_fields
                )
                if cv
                else 0
            )
            / len(photo_and_language_info_fields)
            * 100,
            (100 if cv and cv.work_experiences else 0),
            (100 if cv and cv.references else 0),
            (
                sum(getattr(cv, field) is not None for field in contact_info_fields)
                if cv
                else 0
            )
            / len(contact_info_fields)
            * 100,
        )

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{self.entity.get_resource_name(self.entity.__name__)}s found",
                status_code=200,
            )
        )

        employee = db.query(EmployeeModel).filter_by(user_id=filters.user_id).first()

        if (
            employee
            and round(id_progress) == 100
            and round(address_progress) == 100
            and round(education_progress) == 100
            and round(experience_progress) == 100
            and round(personal_info_progress) == 100
            and round(photo_and_language_progress) == 100
            and round(reference_progress) == 100
            and round(contact_progress) == 100
        ):
            employee.cv_completed = True

        return CVProgressSchema(
            id_progress=round(id_progress),
            address_progress=round(address_progress),
            education_progress=round(education_progress),
            experience_progress=round(experience_progress),
            personal_info_progress=round(personal_info_progress),
            photo_and_language_progress=round(photo_and_language_progress),
            reference_progress=round(reference_progress),
            contact_progress=round(contact_progress),
        )
    
    '''
    def upsert(
        self,
        db: Session,
        *,
        cv_data_json: str,
        head_photo: Optional[UploadFile] = None,
        full_body_photo: Optional[UploadFile] = None,
        intro_video: Optional[UploadFile] = None,
    ) -> EntityType | None:

        print("\n=== Incoming CV Data ===")
        print(f"CV Data JSON: {cv_data_json}")
        print(f"Head Photo: {'Provided' if head_photo else 'Not provided'}")
        print(f"Full Body Photo: {'Provided' if full_body_photo else 'Not provided'}")
        print(f"Intro Video: {'Provided' if intro_video else 'Not provided'}")
        print("========================\n")

        cv_data = json.loads(cv_data_json)
        cv_data["user_id"] = (
            None if cv_data.get("user_id") == None else cv_data["user_id"]
        )

        passport_number = cv_data.get("passport_number")
        
        # Log parsed CV data
        print("\n=== Parsed CV Data ===")
        print(f"User ID: {cv_data.get('user_id')}")
        print(f"Passport Number: {cv_data.get('passport_number')}")
        if 'address' in cv_data:
            print("\nAddress Data:")
            for key, value in cv_data['address'].items():
                print(f"  {key}: {value}")
        if 'education' in cv_data:
            print("\nEducation Data:")
            for key, value in cv_data['education'].items():
                print(f"  {key}: {value}")
        print("=====================\n")

        if passport_number:
            exists = db.query(CVModel).filter_by(passport_number=passport_number).first()
            if exists:
                if str(exists.user_id) != cv_data.get("user_id"):
                    context_set_response_code_message.set(
                        BaseGenericResponse(
                            error=True,
                            message=f"CV with passport number {passport_number} already exists",
                            status_code=400,
                        )
                    )
                    return

        obj_in = CVUpsertSchema(**cv_data)

        if not obj_in.user_id:
            new_user = UserModel()
            new_user.role = UserRoleSchema.EMPLOYEE
            db.add(new_user)
            db.commit()
            obj_in.user_id = new_user.id
            qr_code_data = generate_qr_code(new_user.id)
            new_user_profile = UserProfileModel(
                user_id=new_user.id, qr_code=qr_code_data
            )
            user_id = context_actor_user_data.get().id

            employee = EmployeeModel(
                user_id=new_user.id,
                manager_id=user_id,
            )

            db.add(new_user_profile)
            db.add(employee)
            db.commit()

        existing_cv = db.query(CVModel).filter_by(user_id=obj_in.user_id).first()

        if existing_cv:
            for field, value in obj_in.dict(
                exclude_unset=True,
                exclude=["address", "education", "work_experiences", "references"],
            ).items():
                setattr(existing_cv, field, value)

            if obj_in.address:
                existing_address = (
                    db.query(AddressModel).filter_by(id=existing_cv.address_id).first()
                )
                if existing_address:
                    for field, value in obj_in.address.dict(exclude_unset=True).items():
                        setattr(existing_address, field, value)
                else:
                    new_address = AddressModel(**obj_in.address.dict())
                    existing_cv.address = new_address
                    db.add(new_address)

            if obj_in.education:
                existing_education = (
                    db.query(EducationModel).filter_by(cv_id=existing_cv.id).first()
                )
                if existing_education:
                    for field, value in obj_in.education.dict(
                        exclude_unset=True
                    ).items():
                        setattr(existing_education, field, value)
                else:
                    new_education = EducationModel(**obj_in.education.dict())
                    existing_cv.education = new_education
                    db.add(new_education)

            if head_photo:
                existing_cv.head_photo = uploadFileToLocal(head_photo)
            elif cv_data.get("remove_head_photo"):
                existing_cv.head_photo = None

            if full_body_photo:
                existing_cv.full_body_photo = uploadFileToLocal(full_body_photo)
            elif cv_data.get("remove_full_body_photo"):
                existing_cv.full_body_photo = None

            if intro_video:
                existing_cv.intro_video = uploadFileToLocal(intro_video)
            elif cv_data.get("remove_intro_video"):
                existing_cv.intro_video = None

            if obj_in.work_experiences:
                for we in existing_cv.work_experiences:
                    db.delete(we)
            if obj_in.references:
                for ref in existing_cv.references:
                    db.delete(ref)
            db.commit()

            for we_data in obj_in.work_experiences:
                work_experience = WorkExperienceModel(
                    **we_data.dict(), cv_id=existing_cv.id
                )
                db.add(work_experience)

            for ref_data in obj_in.references:
                reference = ReferenceModel(**ref_data.dict(), cv_id=existing_cv.id)
                db.add(reference)

            db.commit()
            db.refresh(existing_cv)
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} updated successfully",
                    status_code=200,
                )
            )
            return existing_cv
        else:
            new_cv = CVModel(
                **obj_in.dict(
                    exclude=[
                        "address",
                        "education",
                        "references",
                        "work_experiences",
                        "remove_head_photo",
                        "remove_full_body_photo",
                        "remove_intro_video",
                    ]
                )
            )

            if obj_in.address:
                new_address = AddressModel(**obj_in.address.dict())
                new_cv.address = new_address
                db.add(new_address)

            if obj_in.education:
                new_education = EducationModel(**obj_in.education.dict())
                new_cv.education = new_education
                db.add(new_education)

            db.add(new_cv)
            db.commit()

            for we_data in obj_in.work_experiences:
                work_experience = WorkExperienceModel(
                    **we_data.dict(exclude_unset=True), cv_id=new_cv.id
                )
                db.add(work_experience)
            for ref_data in obj_in.references:
                reference = ReferenceModel(
                    **ref_data.dict(exclude_unset=True), cv_id=new_cv.id
                )
                db.add(reference)

            if head_photo:
                new_cv.head_photo = uploadFileToLocal(head_photo)

            if full_body_photo:
                new_cv.full_body_photo = uploadFileToLocal(full_body_photo)

            if intro_video:
                new_cv.intro_video = uploadFileToLocal(intro_video)

            db.commit()
            db.refresh(new_cv)

            if new_cv is not None:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=False,
                        message=f"{self.entity.get_resource_name(self.entity.__name__)} created successfully",
                        status_code=201,
                    )
                )

            return new_cv
    '''

    def upsert(
        self,
        db: Session,
        *,
        cv_data_json: str,
        head_photo: Optional[UploadFile] = None,
        full_body_photo: Optional[UploadFile] = None,
        intro_video: Optional[UploadFile] = None,
    ) -> EntityType | None:

        try:
            print("\n=== Incoming CV Data ===")
            print(f"CV Data JSON: {cv_data_json}")
            print(f"Head Photo: {'Provided' if head_photo else 'Not provided'}")
            print(f"Full Body Photo: {'Provided' if full_body_photo else 'Not provided'}")
            print(f"Intro Video: {'Provided' if intro_video else 'Not provided'}")
            print("========================\n")

            # Parse JSON data
            try:
                cv_data = json.loads(cv_data_json)
            except json.JSONDecodeError as e:
                print(f"Error parsing JSON: {str(e)}")
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message="Invalid JSON data",
                        status_code=400,
                    )
                )
                return None

            # Normalize user_id
            cv_data["user_id"] = None if cv_data.get("user_id") is None else cv_data["user_id"]

            # Log parsed CV data
            print("\n=== Parsed CV Data ===")
            print(f"User ID: {cv_data.get('user_id')}")
            print(f"Passport Number: {cv_data.get('passport_number')}")
            if 'address' in cv_data:
                print("\nAddress Data:")
                for key, value in cv_data['address'].items():
                    print(f"  {key}: {value}")
            if 'education' in cv_data:
                print("\nEducation Data:")
                for key, value in cv_data['education'].items():
                    print(f"  {key}: {value}")
            print("=====================\n")

            # Check for duplicate passport number
            passport_number = cv_data.get("passport_number")
           

            try:
                # Convert to schema
                obj_in = CVUpsertSchema(**cv_data)
            except Exception as e:
                print(f"Error creating CVUpsertSchema: {str(e)}")
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=f"Invalid CV data: {str(e)}",
                        status_code=400,
                    )
                )
                return None

            # Start transaction
            try:
                with db.begin_nested():
                    # Create new user if needed
                    if not obj_in.user_id:
                        new_user = UserModel()
                        new_user.role = UserRoleSchema.EMPLOYEE
                        db.add(new_user)
                        db.flush()
                        
                        obj_in.user_id = new_user.id
                        
                        # Create user profile
                        qr_code_data = generate_qr_code(new_user.id)
                        new_user_profile = UserProfileModel(
                            user_id=new_user.id,
                            qr_code=qr_code_data
                        )
                        
                        # Create employee record
                        user_id = context_actor_user_data.get().id
                        employee = EmployeeModel(
                            user_id=new_user.id,
                            manager_id=user_id,
                        )
                        
                        db.add(new_user_profile)
                        db.add(employee)
                        db.flush()

                    # Check for existing CV
                    existing_cv = db.query(CVModel).filter_by(user_id=obj_in.user_id).first()

                    if existing_cv:
                        print(f"Updating existing CV for user {obj_in.user_id}")
                        
                        # Update basic fields
                        for field, value in obj_in.dict(
                            exclude_unset=True,
                            exclude=["address", "education", "work_experiences", "references"],
                        ).items():
                            setattr(existing_cv, field, value)

                        # Update address
                        if obj_in.address:
                            try:
                                existing_address = db.query(AddressModel).filter_by(id=existing_cv.address_id).first()
                                if existing_address:
                                    for field, value in obj_in.address.dict(exclude_unset=True).items():
                                        setattr(existing_address, field, value)
                                else:
                                    new_address = AddressModel(**obj_in.address.dict())
                                    existing_cv.address = new_address
                                    db.add(new_address)
                            except Exception as e:
                                print(f"Error updating address: {str(e)}")
                                raise
                        if obj_in.education:
                            existing_education = (
                                db.query(EducationModel).filter_by(cv_id=existing_cv.id).first()
                            )
                            if existing_education:
                                for field, value in obj_in.education.dict(
                                    exclude_unset=True
                                ).items():
                                    setattr(existing_education, field, value)
                            else:
                                new_education = EducationModel(**obj_in.education.dict())
                                existing_cv.education = new_education
                                db.add(new_education)

                        # Handle file uploads
                        if head_photo:
                            existing_cv.head_photo = uploadFileToLocal(head_photo)
                        elif cv_data.get("remove_head_photo"):
                            existing_cv.head_photo = None

                        if full_body_photo:
                            existing_cv.full_body_photo = uploadFileToLocal(full_body_photo)
                        elif cv_data.get("remove_full_body_photo"):
                            existing_cv.full_body_photo = None

                        if intro_video:
                            existing_cv.intro_video = uploadFileToLocal(intro_video)
                        elif cv_data.get("remove_intro_video"):
                            existing_cv.intro_video = None

                        # Handle work experiences and references
                        if obj_in.work_experiences:
                            for we in existing_cv.work_experiences:
                                db.delete(we)
                            for we_data in obj_in.work_experiences:
                                work_experience = WorkExperienceModel(
                                    **we_data.dict(), cv_id=existing_cv.id
                                )
                                db.add(work_experience)

                        if obj_in.references:
                            for ref in existing_cv.references:
                                db.delete(ref)
                            for ref_data in obj_in.references:
                                reference = ReferenceModel(**ref_data.dict(), cv_id=existing_cv.id)
                                db.add(reference)

                        db.flush()
                        context_set_response_code_message.set(
                            BaseGenericResponse(
                                error=False,
                                message=f"{self.entity.get_resource_name(self.entity.__name__)} updated successfully",
                                status_code=200,
                            )
                        )
                        return existing_cv

                    else:
                        print(f"Creating new CV for user {obj_in.user_id}")
                        
                        # Create new CV
                        new_cv = CVModel(
                            **obj_in.dict(
                                exclude=[
                                    "address",
                                    "education",
                                    "references",
                                    "work_experiences",
                                    "remove_head_photo",
                                    "remove_full_body_photo",
                                    "remove_intro_video",
                                ]
                            )
                        )

                        # Create address
                        if obj_in.address:
                            try:
                                new_address = AddressModel(**obj_in.address.dict())
                                new_cv.address = new_address
                                db.add(new_address)
                            except Exception as e:
                                print(f"Error creating address: {str(e)}")
                                raise

                        # Create education
                        if obj_in.education:
                            new_education = EducationModel(**obj_in.education.dict())
                            new_cv.education = new_education
                            db.add(new_education)

                        db.add(new_cv)
                        db.flush()

                        # Create work experiences and references
                        if obj_in.work_experiences:
                            for we_data in obj_in.work_experiences:
                                work_experience = WorkExperienceModel(
                                    **we_data.dict(exclude_unset=True), cv_id=new_cv.id
                                )
                                db.add(work_experience)

                        if obj_in.references:
                            for ref_data in obj_in.references:
                                reference = ReferenceModel(
                                    **ref_data.dict(exclude_unset=True), cv_id=new_cv.id
                                )
                                db.add(reference)

                        # Handle file uploads
                        if head_photo:
                            new_cv.head_photo = uploadFileToLocal(head_photo)

                        if full_body_photo:
                            new_cv.full_body_photo = uploadFileToLocal(full_body_photo)

                        if intro_video:
                            new_cv.intro_video = uploadFileToLocal(intro_video)

                        db.flush()
                        context_set_response_code_message.set(
                            BaseGenericResponse(
                                error=False,
                                message=f"{self.entity.get_resource_name(self.entity.__name__)} created successfully",
                                status_code=201,
                            )
                        )
                        return new_cv

            except Exception as e:
                print(f"Database error during CV upsert: {str(e)}")
                db.rollback()
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=f"Database error: {str(e)}",
                        status_code=500,
                    )
                )
                return None

        except Exception as e:
            print(f"Unexpected error in CV upsert: {str(e)}")
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="An unexpected error occurred",
                    status_code=500,
                )
            )
            return None
        


    def delete(self, db: Session, filters: FilterSchemaType) -> EntityType:
        return super().delete(db, filters)

    '''
    def upload_passport(
        self, db: Session, user_id: Optional[uuid.UUID], file: UploadFile
    ):
        try:
            file_path = uploadFileToLocal(file)
            user_data = read_mrz(file_path)
            cv = dict()
            cv["user_id"] = str(user_id)
            cv["english_full_name"] = user_data["name"] + " " + user_data["surname"]
            cv["nationality"] = user_data["nationality"]
            cv["passport_number"] = user_data["document_number"]
            name = cv["english_full_name"].split()
            for i in range(len(name)):
                name[i] = name[i].capitalize()
            cv["english_full_name"] = " ".join(name)
            date_obj = datetime.strptime(user_data["birth_date"], "%y%m%d")
            if date_obj.year > datetime.now().year:
                date_obj = date_obj.replace(year=date_obj.year - 100)
            formatted_date = date_obj.strftime("%Y-%m-%d")
            cv["date_of_birth"] = formatted_date
            cv["sex"] = SexSchema.MALE if user_data["sex"] == "M" else SexSchema.FEMALE
            cv["passport_url"] = file_path
            return self.upsert(db, cv_data_json=json.dumps(cv))
        
        except Exception as e:
            cv = dict()
            cv["user_id"] = str(user_id)
            cv["passport_url"] = file_path
            print('file_path', file_path)
            self.upsert(db, cv_data_json=json.dumps(cv))
            
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="Unable to read information from the passport, but passport image was saved",
                    status_code=400,
                )
            )
    '''

    def upload_passport(
            self, db: Session, user_id: Optional[uuid.UUID], file: UploadFile
        ):
            try:
                file_path = uploadFileToLocal(file)
                
                cv = dict()
                cv["user_id"] = str(user_id) if user_id is not None else None
                cv["passport_url"] = file_path

                print("File saved to:", file_path)
                print("CV data before upsert:", cv)

                return self.upsert(db, cv_data_json=json.dumps(cv))

            except Exception as e:
                import traceback
                print("Upload error:", str(e))
                traceback.print_exc()

                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=f"Unable to upload the passport image: {str(e)}",
                        status_code=400,
                    )
                )


            


                
    def bulk_upload(self, db: Session, file: BytesIO):
        try:
            df = pd.read_excel(
                file,
                dtype={
                    "phone_number": str,
                    "height": float,
                    "weight": float,
                    "address_street": str,
                    "national_id": str,
                },
            )
            df = df.map(lambda x: None if pd.isna(x) or x == "" else x)

            created_cvs = []

            for _, row in df.iterrows():
                cv_data = row.to_dict()

                # Split out nested fields
                address_data = {
                    key.replace("address_", ""): value
                    for key, value in cv_data.items()
                    if key.startswith("address_")
                }
                education_data = {
                    key.replace("education_", ""): value
                    for key, value in cv_data.items()
                    if key.startswith("education_")
                }

                # Strip from main dict
                cv_data = {
                    key: value
                    for key, value in cv_data.items()
                    if not key.startswith("address_") and not key.startswith("education_")
                }

                cv_data["address"] = address_data
                cv_data["education"] = education_data

                # Convert timestamps to strings
                for key, value in cv_data.items():
                    if isinstance(value, pd.Timestamp):
                        cv_data[key] = value.strftime('%Y-%m-%d')

                # Convert to JSON
                cv_data_json = json.dumps(cv_data)

                # Call upsert (returns CVModel or None)
                cv_instance = self.upsert(
                    db,
                    cv_data_json=cv_data_json,
                    head_photo=None,
                    full_body_photo=None,
                    intro_video=None,
                )

                if cv_instance:
                    created_cvs.append(cv_instance)

            db.commit()

            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"Successfully processed {len(created_cvs)} CVs.",
                    status_code=201,
                )
            )

            return created_cvs

        except Exception as e:
            logger.error(f"Error in bulk_upload: {e}")
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="An error occurred while processing the bulk upload.",
                    status_code=500,
                )
            )
            return None

        
    '''
    def export_to_pdf(
        self, db: Session, *, request: Request, title: str, filters: CVFilterSchema
    ):
        templates = Jinja2Templates(directory="templates")
        entity = db.query(CVModel).filter_by(user_id=filters.user_id).first()
        qr_code = my_qr_code(f"{settings.FRONTEND_PUBLIC_CV_URL}/{entity.id}")
        if not entity:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=200,
                )
            )
            return None

        owner_data = {}

        if entity.user.employees:
            manager_id = entity.user.employees[0].manager_id
            manager = db.query(UserModel).filter(UserModel.id == manager_id).first()

            if manager.role == "agent" or manager.role == "recruitment" or manager.role == "sponsor":
                owner_data = {
                    "company_name": manager.company.company_name,
                    "name": f"{manager.first_name} {manager.last_name}",
                    "phone_number": manager.phone_number,
                    "email": manager.email,
                    "location": manager.company.location
            }

        rate = 0

        additional_languages = []

        additional_languages.append({
            "language": "Amharic",
            "proficiency": entity.amharic
        })

        additional_languages.append({
            "language": "Arabic",
            "proficiency": entity.arabic
        })

        additional_languages.append({
            "language": "English",
            "proficiency": entity.english
        })

        if entity.references:
            rate += 1

        if entity.work_experiences:
            if len(entity.work_experiences) >= 2:
                rate += 2
            elif len(entity.work_experiences) == 1:
                rate += 1
        if entity.additional_languages:
            if len(entity.additional_languages) > 2:
                rate += 1.5
            elif len(entity.additional_languages) == 2:
                rate += 1
            else:
                rate += 0.5

            for lang in entity.additional_languages:
                additional_languages.append({
                    "language": lang.language.capitalize().rstrip().lstrip(),
                    "proficiency": lang.proficiency
                })

        additional_languages.sort(key=lambda x: x["language"], reverse=False)

        if entity.education and entity.education.highest_level in ["bsc", "msc", "phd"]:
            template = templates.get_template("cv.html")
        else:
            template = templates.get_template("cv_non_graduate.html")

        age = 0

        try:
            date_str = entity.date_of_birth.split('T')[0]
            age = datetime.now().year - datetime.strptime(date_str, "%Y-%m-%d").year
        except Exception as e:
            print(e)
        try:
            content = template.render(
                request=request,
                user=entity, 
                img_base64=qr_code, 
                passport_url=entity.passport_url,
                base_url=f"{settings.BASE_URL}/static",
                rate=rate,
                additional_languages=additional_languages,
                owner=owner_data,
                description=entity.summary,
                age=age
            )

        except Exception as e:
            print(e)
        return content
    '''


    '''
    def export_to_pdf(
            self, db: Session, *, request: Request, title: str, filters: CVFilterSchema
        ):
            logger = logging.getLogger(__name__)
            logger.info(f"Starting PDF export for CV with filters: {filters}")
            
            templates = Jinja2Templates(directory="templates")
            entity = db.query(CVModel).filter_by(user_id=filters.user_id).first()
            qr_code = my_qr_code(f"{settings.FRONTEND_PUBLIC_CV_URL}/{entity.id}")
            
            if not entity:
                logger.warning(f"CV not found for user_id: {filters.user_id}")
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                        status_code=200,
                    )
                )
                return None

            logger.info(f"Found CV for user_id: {filters.user_id}, proceeding with PDF generation")

            owner_data = {}

            if entity.user.employees:
                manager_id = entity.user.employees[0].manager_id
                manager = db.query(UserModel).filter(UserModel.id == manager_id).first()

                if manager.role == "agent" or manager.role == "recruitment" or manager.role == "sponsor":
                    owner_data = {
                        "company_name": manager.company.company_name,
                        "name": f"{manager.first_name} {manager.last_name}",
                        "phone_number": manager.phone_number,
                        "email": manager.email,
                        "location": manager.company.location
                    }
                    logger.debug(f"Added owner data for manager: {manager.id}")

            rate = 0
            additional_languages = []

            additional_languages.append({
                "language": "Amharic",
                "proficiency": entity.amharic
            })

            additional_languages.append({
                "language": "Arabic",
                "proficiency": entity.arabic
            })

            additional_languages.append({
                "language": "English",
                "proficiency": entity.english
            })

            if entity.references:
                rate += 1
                logger.debug("Added rate point for references")

            if entity.work_experiences:
                if len(entity.work_experiences) >= 2:
                    rate += 2
                elif len(entity.work_experiences) == 1:
                    rate += 1
                logger.debug(f"Added rate points for work experiences: {rate}")

            if entity.additional_languages:
                if len(entity.additional_languages) > 2:
                    rate += 1.5
                elif len(entity.additional_languages) == 2:
                    rate += 1
                else:
                    rate += 0.5

                for lang in entity.additional_languages:
                    additional_languages.append({
                        "language": lang.language.capitalize().rstrip().lstrip(),
                        "proficiency": lang.proficiency
                    })
                logger.debug(f"Added rate points for additional languages: {rate}")

            additional_languages.sort(key=lambda x: x["language"], reverse=False)

            if entity.education and entity.education.highest_level in ["bsc", "msc", "phd"]:
                template = templates.get_template("cv.html")
                logger.debug("Using graduate CV template")
            else:
                template = templates.get_template("cv_non_graduate.html")
                logger.debug("Using non-graduate CV template")

            age = 0

            try:
                date_str = entity.date_of_birth.split('T')[0]
                age = datetime.now().year - datetime.strptime(date_str, "%Y-%m-%d").year
                logger.debug(f"Calculated age: {age}")
            except Exception as e:
                logger.error(f"Error calculating age: {str(e)}")
                print(e)

            try:
                content = template.render(
                    request=request,
                    user=entity, 
                    img_base64=qr_code, 
                    passport_url=entity.passport_url,
                    base_url=f"{settings.BASE_URL}/static",
                    rate=rate,
                    additional_languages=additional_languages,
                    owner=owner_data,
                    description=entity.summary,
                    age=age
                )
                logger.info(f"Successfully generated PDF content for CV: {entity.id}")

            except Exception as e:
                logger.error(f"Error generating PDF content: {str(e)}")
                print(e)
                
            return content
        
    '''



    def export_to_pdf(
        self, db: Session, *, request: Request, title: str, filters: CVFilterSchema
    ):
        logger = logging.getLogger(__name__)
        logger.info(f"Starting PDF export for CV with filters: {filters}")
        
        templates = Jinja2Templates(directory="templates")
        entity = db.query(CVModel).filter_by(user_id=filters.user_id).first()
        qr_code = my_qr_code(f"{settings.FRONTEND_PUBLIC_CV_URL}/{entity.id}")
        
        if not entity:
            logger.warning(f"CV not found for user_id: {filters.user_id}")
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=200,
                )
            )
            return None

        logger.info(f"Found CV for user_id: {filters.user_id}, proceeding with PDF generation")

        owner_data = {}

        try:
            # Check if user exists and has employees
            if hasattr(entity, 'user') and entity.user is not None:
                if hasattr(entity.user, 'employees') and entity.user.employees:
                    # Get the first employee's manager_id
                    manager_id = entity.user.employees[0].manager_id
                    
                    # Query the manager
                    manager = db.query(UserModel).filter(UserModel.id == manager_id).first()
                    
                    if manager is not None:
                        # Check manager role
                        if hasattr(manager, 'role') and manager.role in ["agent", "recruitment", "sponsor"]:
                            # Safely get company data
                            company = getattr(manager, 'company', None)
                            
                            # Build owner data with safe defaults
                            owner_data = {
                                "company_name": getattr(company, 'company_name', '') if company else '',
                                "name": f"{getattr(manager, 'first_name', '')} {getattr(manager, 'last_name', '')}".strip(),
                                "phone_number": getattr(manager, 'phone_number', ''),
                                "email": getattr(manager, 'email', ''),
                                "location": getattr(company, 'location', '') if company else ''
                            }
                            logger.debug(f"Added owner data for manager: {manager.id}")
        except Exception as e:
            logger.warning(f"Error processing manager data: {str(e)}")
            # Continue with empty owner_data if there's an error

        rate = 0
        additional_languages = []

        # Safely add language proficiencies with null checks
        if hasattr(entity, 'amharic') and entity.amharic:
            additional_languages.append({
                "language": "Amharic",
                "proficiency": entity.amharic
            })

        if hasattr(entity, 'arabic') and entity.arabic:
            additional_languages.append({
                "language": "Arabic",
                "proficiency": entity.arabic
            })

        if hasattr(entity, 'english') and entity.english:
            additional_languages.append({
                "language": "English",
                "proficiency": entity.english
            })

        if hasattr(entity, 'references') and entity.references:
            rate += 1
            logger.debug("Added rate point for references")

        if hasattr(entity, 'work_experiences') and entity.work_experiences:
            if len(entity.work_experiences) >= 2:
                rate += 2
            elif len(entity.work_experiences) == 1:
                rate += 1
            logger.debug(f"Added rate points for work experiences: {rate}")

        if hasattr(entity, 'additional_languages') and entity.additional_languages:
            if len(entity.additional_languages) > 2:
                rate += 1.5
            elif len(entity.additional_languages) == 2:
                rate += 1
            else:
                rate += 0.5

            for lang in entity.additional_languages:
                if lang and hasattr(lang, 'language') and lang.language:
                    additional_languages.append({
                        "language": lang.language.capitalize().rstrip().lstrip(),
                        "proficiency": getattr(lang, 'proficiency', '')
                    })
            logger.debug(f"Added rate points for additional languages: {rate}")

        additional_languages.sort(key=lambda x: x["language"], reverse=False)

        # Safely check education level
        education = getattr(entity, 'education', None)
        education_level = getattr(education, 'highest_level', None) if education else None
        
        if education_level in ["bsc", "msc", "phd"]:
            template = templates.get_template("cv.html")
            logger.debug("Using graduate CV template")
        else:
            template = templates.get_template("cv_non_graduate.html")
            logger.debug("Using non-graduate CV template")

        age = 0

        try:
            if hasattr(entity, 'date_of_birth') and entity.date_of_birth:
                date_str = entity.date_of_birth.split('T')[0]
                age = datetime.now().year - datetime.strptime(date_str, "%Y-%m-%d").year
                logger.debug(f"Calculated age: {age}")
        except Exception as e:
            logger.error(f"Error calculating age: {str(e)}")
            print(e)
        
        def build_video_url(entity) -> str:
            try:
                if hasattr(entity, 'intro_video') and entity.intro_video:
                    return f"{settings.BASE_URL}/static/videos/uploads/{entity.intro_video.strip('/')}"
            except Exception as e:
                logging.getLogger(__name__).error(f"Error building video URL: {str(e)}")
            return ""


        video_url = build_video_url(entity)


        try:
            content = template.render(
                request=request,
                user=entity, 
                img_base64=qr_code, 
                passport_url=getattr(entity, 'passport_url', ''),
               
                base_url=f"{settings.BASE_URL}/static",
                rate=rate,
                additional_languages=additional_languages,
                owner=owner_data,
                description=getattr(entity, 'summary', ''),
                age=age,
                video_url=video_url
            )
            
            logger.info(f"Successfully generated PDF content for CV: {entity.id}")

        except Exception as e:
            logger.error(f"Error generating PDF content: {str(e)}")
            print(e)
            
        return content

    def export_to_pdf_saudi(
        self, db: Session, *, request: Request, title: str, filters: CVFilterSchema
    ):
        templates = Jinja2Templates(directory="templates")
        entity = db.query(CVModel).filter_by(user_id=filters.user_id).first()
        if not entity:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=200,
                )
            )
            return None

        file_path = f"{entity.english_full_name}_saudi.html"

        template = templates.get_template("Saudi.html")
        content = template.render(
            request=request, user=entity, base_url="https://api.marrir.com/static"
        )

        return content

    def get_additional_languages(self, db: Session, filters: CVFilterSchema):
        cv = db.query(CVModel).filter_by(id=filters.id).first()

        if not cv:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=404,
                )
            )
            return None

        languages = db.query(AdditionalLanguageModel).filter_by(cv_id=filters.id).all()

        if len(languages) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message="No additional languages found!",
                    status_code=200,
                )
            )
            return []

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{len(languages)} additional languages found!",
                status_code=200,
            )
        )
        return languages

    def add_language(self, db: Session, obj_in: AdditionalLanguageCreateSchema):
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = AdditionalLanguageModel(**obj_in_data)
        exists = (
            db.query(AdditionalLanguageModel)
            .filter_by(language=obj_in.language, cv_id=obj_in.cv_id)
            .first()
        )
        if exists:
            exists.proficiency = obj_in.proficiency
            db.commit()
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{obj_in.language} updated successfully",
                    status_code=200,
                )
            )
            return exists

        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)

        if db_obj is not None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{obj_in.language} added successfully",
                    status_code=201,
                )
            )
        return db_obj

    def delete_language(
        self, db: Session, filters: AdditionalLanguageReadSchema
    ) -> EntityType:
        language = db.query(AdditionalLanguageModel).filter_by(id=filters.id).first()
        if not language:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"Language not found!",
                    status_code=404,
                )
            )
            return None

        db.delete(language)
        db.commit()
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message="Language deleted successfully",
                status_code=200,
            )
        )
        return language
