from enum import Enum
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib
from datetime import datetime, timedelta
from http.client import HTTPException
from io import BytesIO
from operator import or_
import random
import secrets
import uuid
from authlib.integrations.starlette_client import OAuth
from typing import Any, Dict, Optional, Type, Union, Generic, List
from fastapi import File, Form, UploadFile
from fastapi.encoders import jsonable_encoder
from fastapi.responses import StreamingResponse
import pandas as pd
import io

from sqlalchemy import BinaryExpression, and_, column
from sqlalchemy.orm import Session
from core.auth import RBACAccessType

from core.context_vars import context_set_response_code_message, context_actor_user_data
from core.security import (
    encode_user_access_token,
    encode_user_refresh_token,
    decode_user_refresh_token,
    decode_user_access_token,
)
from core.security import verify_password
from models.addressmodel import AddressModel
from models.companyinfomodel import CompanyInfoModel
from models.cvmodel import CVModel
from models.educationmodel import EducationModel
from models.employeemodel import EmployeeModel
from models.notificationmodel import NotificationModel
from models.profileviewmodel import ProfileViewModel
from models.ratingmodel import RatingModel
from models.transfermodel import TransferModel
from models.usermodel import UserModel
from models.userprofilemodel import UserProfileModel
from models.workexperiencemodel import WorkExperienceModel
from repositories.base import (
    BaseRepository,
    EntityType,
    UpdateSchemaType,
    CreateSchemaType,
    FilterSchemaType,
)
from repositories.notification import NotificationRepository
from schemas.base import BaseGenericResponse
from schemas.cvschema import CVFilterSchema, RedactedCVReadSchema
from schemas.enumschema import RatingTypeSchema
from schemas.notificationschema import (
    NotificationCreateSchema,
    NotificationReceipentTypeSchema,
    NotificationTypeSchema,
)
from schemas.ratingschema import UserRatingSchema
from schemas.transferschema import TransferStatusSchema
from schemas.userschema import (
    EmailRequest,
    EmployeeReadSchema,
    OTPRequest,
    PasswordResetRequest,
    RedactedEmployeeReadSchema,
    UserCVFilterSchema,
    UserCreateSchema,
    UserProfileViewSchema,
    UserRoleSchema,
    UserUpdateSchema,
    UserLoginSchema,
    UserFilterSchema,
    UserTokenSchema,
    UserTokenResponseSchema,
)
from utils.send_email import send_email
from utils.generate_qr import generate_qr_code
import logging

# Configure logging
logger = logging.getLogger(__name__)


def send_emails(to_email: str, subject: str, body: str):
    # from_email = "muktarabdulmelik9@gmail.com"
    # app_password = "ppaz whzx xsxz indm"  # 16-character app password
    # from_email = 'portalmarrir@gmail.com'
    # app_password = "otta bmgi xqez hzmu"

    msg = MIMEMultipart()
    msg["From"] = from_email
    msg["To"] = to_email
    msg["Subject"] = subject

    msg.attach(MIMEText(body, "plain"))

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(from_email, app_password)
            server.send_message(msg)
        print(f"Email sent to {to_email}")
    except Exception as e:
        print(f"Failed to send email: {e}")


class UserRepository(BaseRepository[UserModel, UserCreateSchema, UserUpdateSchema]):
    def get_by_id(self, db: Session, entity_id: int) -> EntityType:
        return super().get_by_id(db, entity_id)

    def get(self, db: Session, filters: FilterSchemaType) -> EntityType:
        return super().get(db, filters)

    def get_managed_employee_cv_info(
        self,
        db: Session,
        skip: int,
        limit: int,
        search: Optional[str],
        search_schema: Optional[any],
        start_date: Optional[datetime],
        end_date: Optional[datetime],
        manager_id: Optional[uuid.UUID] = None,
        filters: Optional[UserCVFilterSchema] = None,
    ):
        query = db.query(EmployeeModel.user_id, EmployeeModel.status)
        if manager_id:
            query = query.filter(EmployeeModel.manager_id == manager_id)

        employee_id_status = query.all()

        employee_ids = [id for id, _ in employee_id_status]
        query = (
            db.query(UserModel, EmployeeModel.status)
            .outerjoin(EmployeeModel, UserModel.id == EmployeeModel.user_id)
            .outerjoin(CVModel, UserModel.id == CVModel.user_id)
            .filter(UserModel.id.in_(employee_ids))
            .order_by(UserModel.created_at.desc())
        )

        if search:
            search_filter = self.build_generic_search_filter(
                CVModel, search_schema, search
            )
            if search_filter is not None:
                query = query.filter(search_filter)

        filters_conditions = self.custom_cv_filter(
            CVModel, filters.__dict__ if filters else {}
        )

        # query = query.filter(filters_conditions[0])

        if start_date and end_date:
            query = query.filter(
                and_(
                    self.entity.created_at >= start_date,
                    self.entity.created_at <= end_date,
                )
            )

        total_count = query.count()
        cv_info = query.offset(skip).limit(limit).all()
        print(len(cv_info))
        results = []
        for user, status in cv_info:
            user_data = {
                "id": user.id,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "email": user.email,
                "phone_number": user.phone_number,
                "country": user.country,
                "role": user.role,
                "cv": user.cv,
                "status": status,
                "process": user.process,
                "profile": user.profile,
                "company": user.company,
                "notification_reads": user.notification_reads,
                "user_notifications": user.user_notifications,
                "verified": user.verified,
                "created_at": user.created_at,
            }
            results.append(user_data)
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"Employees CVs found",
                status_code=200,
                count=total_count,
            )
        )

        return results

    def custom_cv_filter(self, model, filters_dict):
        conditions = []

        for key, value in filters_dict.items():
            if (
                value is not None
                and not key.startswith("min_")
                and not key.startswith("max_")
            ):
                field = getattr(model, key, None)
                if field is not None:
                    conditions.append(field == value)

        range_filters = [
            ("min_height", "max_height", "height"),
            ("min_weight", "max_weight", "weight"),
            ("min_age", "max_age", "age"),
        ]

        for min_key, max_key, model_field in range_filters:
            min_value = filters_dict.get(min_key)
            max_value = filters_dict.get(max_key)
            field = getattr(model, model_field, None)

            if field is not None:
                if min_value is not None:
                    conditions.append(field >= min_value)
                if max_value is not None:
                    conditions.append(field <= max_value)

        return and_(*conditions), len(conditions)

    def get_employee_detail(
        self, db: Session, employee_id: str, redacted: bool
    ) -> EntityType | None:
        user_cv = (
            db.query(UserModel, CVModel)
            .outerjoin(CVModel, UserModel.id == CVModel.user_id)
            .filter(UserModel.id == employee_id)
            .first()
        )

        user, cv = user_cv if user_cv else (None, None)

        if user is None:
            pass

        education = None
        work_experiences = []
        ratings = []

        if cv:
            education = (
                db.query(EducationModel).filter(
                    EducationModel.cv_id == cv.id).first()
            )
            work_experiences = (
                db.query(WorkExperienceModel)
                .filter(WorkExperienceModel.cv_id == cv.id)
                .all()
            )

        ratings = (
            db.query(RatingModel).filter(RatingModel.user_id == user.id).all()
            if user
            else []
        )
        admin_rating = (
            db.query(RatingModel.value)
            .filter(
                RatingModel.user_id == user.id,
                RatingModel.type == RatingTypeSchema.ADMIN,
            )
            .all()
        )

        test_rating = (
            db.query(RatingModel.value)
            .filter(
                RatingModel.user_id == user.id,
                RatingModel.type == RatingTypeSchema.TEST,
            )
            .all()
        )

        sponsor_rating = (
            db.query(RatingModel.value)
            .filter(
                RatingModel.user_id == user.id,
                RatingModel.type == RatingTypeSchema.SPONSOR,
            )
            .all()
        )

        admin_rating_values = [rating.value for rating in admin_rating]
        test_rating_values = [rating.value for rating in test_rating]
        sponsor_rating_values = [rating.value for rating in sponsor_rating]

        rating = UserRatingSchema(
            admin_rating=sum(admin_rating_values) /
            max(1, len(admin_rating_values)),
            self_rating=sum(test_rating_values) /
            max(1, len(test_rating_values)),
            sponsor_rating=sum(sponsor_rating_values)
            / max(1, len(sponsor_rating_values)),
        )

        cv_completed = (
            db.query(EmployeeModel.cv_completed)
            .filter(EmployeeModel.user_id == user.id)
            .first()
        )

        employee = EmployeeReadSchema(
            id=user.id,
            first_name=user.first_name,
            last_name=user.last_name,
            cv=cv,
            email=user.email,
            rating=rating,
            education=education,
            work_experiences=work_experiences,
            cv_completed=cv_completed[0],
        )

        redacted_employee = RedactedEmployeeReadSchema(
            id=user.id,
            first_name=user.first_name,
            last_name=user.last_name,
            rating=rating,
            cv=(
                RedactedCVReadSchema(
                    id=cv.id,
                    english_full_name=cv.english_full_name,
                    arabic_full_name=cv.arabic_full_name,
                    amharic_full_name=cv.amharic_full_name,
                    religion=cv.religion,
                    sex=cv.sex,
                    date_of_birth=cv.date_of_birth,
                    place_of_birth=cv.place_of_birth,
                    height=cv.height,
                    weight=cv.weight,
                    head_photo=cv.head_photo,
                    full_body_photo=cv.full_body_photo,
                    intro_video=cv.intro_video,
                    marital_status=cv.marital_status,
                    nationality=cv.nationality,
                    occupation=cv.occupation,
                    number_of_children=cv.number_of_children,
                    skin_tone=cv.skin_tone,
                    amharic=cv.amharic,
                    english=cv.english,
                    arabic=cv.arabic,
                    additional_languages=cv.additional_languages,
                )
                if cv
                else None
            ),
            education=education,
            work_experiences=work_experiences,
        )

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message="Employee found",
                status_code=200,
            )
        )

        return employee if not redacted else redacted_employee

    def get_managed_employees(
        self,
        db: Session,
        skip: int,
        limit: int,
        search: Optional[str],
        search_schema: Optional[any],
        start_date: Optional[datetime],
        end_date: Optional[datetime],
        manager_id: uuid.UUID,
    ) -> List[EntityType]:
        employee_ids = (
            db.query(EmployeeModel.user_id)
            .filter(
                EmployeeModel.manager_id == manager_id,
            )
            .all()
        )

        employee_ids = [id[0] for id in employee_ids]

        query = db.query(self.entity)

        if search:
            search_filter = self.build_generic_search_filter(
                self.entity, search_schema, search
            )
            if search_filter is not None:
                query = query.filter(search_filter)

        if start_date and end_date:
            query = query.filter(
                and_(
                    self.entity.created_at >= start_date,
                    self.entity.created_at <= end_date,
                )
            )

        total_count = query.count()

        entities = (
            query.filter(UserModel.id.in_(employee_ids))
            .order_by(UserModel.first_name.asc())
            .offset(skip)
            .limit(limit)
            .all()
        )

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s not found / not found in the ",
                    status_code=404,
                )
            )
        elif len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No {self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                    count=0,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                    count=total_count,
                )
            )
        return entities

    def get_some(
        self,
        db: Session,
        skip: int,
        limit: int,
        search: Optional[str],
        search_schema: Optional[any],
        start_date: Optional[str],
        end_date: Optional[str],
        filters: FilterSchemaType,
        # sort_field: Optional[Dict[any, str]] = None,
        # sort_order: str = "asc",
    ) -> List[EntityType]:
        return super().get_some(
            db,
            skip,
            limit,
            search,
            search_schema,
            start_date,
            end_date,
            filters,
            # sort_field,
            # sort_order
        )

    def get_some_non_employee(
        self,
        db: Session,
        skip: int,
        limit: int,
        search: Optional[str],
        search_schema: Optional[any],
        start_date: Optional[datetime],
        end_date: Optional[datetime],
        filters: FilterSchemaType,
        # sort_field: Optional[Dict[any, str]] = None,
        # sort_order: str = "asc",
    ) -> List[EntityType]:
        query = db.query(self.entity)

        filters_conditions = self.build_filters(
            self.entity, filters.__dict__ if filters else {}
        )

        query = query.filter(filters_conditions)

        # if sort_field:
        #     for model, field in sort_field.items():
        #         if sort_order == "asc":
        #             query = query.order_by(getattr(model, field).asc())
        #         else:
        #             query = query.order_by(getattr(model, field).desc())

        total_count = query.count()

        if search:
            query = query.join(
                CompanyInfoModel, UserModel.id == CompanyInfoModel.user_id
            )

            search_filter = self.build_generic_search_filter(
                self.entity, search_schema, search
            )
            if search_filter is not None:
                query = query.filter(search_filter)

        if start_date and end_date:
            query = query.filter(
                and_(
                    self.entity.created_at >= start_date,
                    self.entity.created_at <= end_date,
                )
            )

        entities = query.offset(skip).limit(limit).all()

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s not found / not found in the ",
                    status_code=404,
                )
            )
        elif len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No {self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                    count=0,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                    count=total_count,
                )
            )
        return entities

    def get_all(self, db: Session, filters: FilterSchemaType) -> List[EntityType]:
        return super().get_all(db, filters)

    def get_qr_code(self, db: Session, filters: UserFilterSchema) -> EntityType:
        user_profile = (
            db.query(UserProfileModel)
            .filter(UserProfileModel.user_id == filters.id)
            .first()
        )
        if not user_profile:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found!",
                    status_code=409,
                )
            )
            return None

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{self.entity.get_resource_name(self.entity.__name__)} found!",
                status_code=200,
            )
        )
        return StreamingResponse(BytesIO(user_profile.qr_code), media_type="image/png")

    def request_password_reset(self, db: Session, request_in: EmailRequest):
        user = db.query(UserModel).filter_by(email=request_in.email).first()
        if not user:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="User not found!",
                    status_code=400,
                )
            )
            return None

        current_time = datetime.now()
        if user.otp and current_time < user.otp_expiry:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message="OTP still valid!",
                    status_code=200,
                )
            )

            return {"OTP": user.otp, "expiry_time": user.otp_expiry}

        otp = str(random.randint(100000, 999999))
        otp_expiry = current_time + timedelta(minutes=5)
        user.otp = otp
        user.otp_expiry = otp_expiry
        subject = "Your OTP for Password Reset"
        body = f"Here is your OTP: {otp}"
        send_email(email=user.email, title=subject, description=body)

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message="OTP sent to your email.",
                status_code=200,
            )
        )

        return {"OTP": otp, "expiry_time": otp_expiry}

    def resend_otp(self, db: Session, request_in: EmailRequest):
        user = db.query(UserModel).filter_by(email=request_in.email).first()
        if not user:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="User not found!",
                    status_code=400,
                )
            )
            return None
        current_time = datetime.now()
        otp = str(random.randint(100000, 999999))
        otp_expiry = current_time + timedelta(minutes=5)
        user.otp = otp
        user.otp_expiry = otp_expiry
        subject = "Your OTP for Password Reset"
        body = f"Here is your OTP: {otp}"
        send_email(user.email, subject, body)

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message="OTP sent to your email.",
                status_code=200,
            )
        )

        return {"OTP": otp, "expiry_time": otp_expiry}

    def verify_otp(self, db: Session, obj_in: OTPRequest):
        user = db.query(UserModel).filter_by(email=obj_in.email).first()

        if not user or user.otp != obj_in.otp:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="Invalid OTP",
                    status_code=400,
                )
            )
            return None
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message="OTP verified successfully",
                status_code=200,
            )
        )

    def reset_password(self, db: Session, data: PasswordResetRequest):
        user = db.query(UserModel).filter_by(email=data.email).first()
        if not user or user.otp != data.otp:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="Invalid OTP",
                    status_code=400,
                )
            )
            return None
        if data.new_password != data.confirm_password:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="Passwords do not match",
                    status_code=400,
                )
            )
            return None
        # Here, you would hash the password. For simplicity, let's just store it directly.
        user.password = data.new_password
        user.otp = None
        user.otp_expiry = None
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message="Password updated successfully",
                status_code=200,
            )
        )

    '''
    def create(self, db: Session, *, obj_in: UserCreateSchema) -> EntityType | None:
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.entity(**obj_in_data)
        exists = self.check_conflict(db, entity=db_obj)
        if exists:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"User Already Exists!",
                    status_code=409,
                )
            )
            return None

        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)

        qr_code_data = generate_qr_code(db_obj.id)
        new_user_profile = UserProfileModel(user_id=db_obj.id, qr_code=qr_code_data)
        user = context_actor_user_data.get()
        db.add(new_user_profile)

        if obj_in.role == UserRoleSchema.EMPLOYEE:
            employee = EmployeeModel(user_id=db_obj.id, manager_id=db_obj.id)
            if user:
                employee.manager_id = user.id
            db.add(employee)
            new_cv = CVModel(
                user_id=db_obj.id,
                english_full_name=db_obj.first_name + " " + db_obj.last_name,
                email=db_obj.email,
                phone_number=db_obj.phone_number,
            )
            db.add(new_cv)

        db.commit()

        if db_obj is not None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} created successfully",
                    status_code=201,
                )
            )
        return db_obj
    '''

    def create(self, db: Session, *, obj_in: UserCreateSchema) -> EntityType | None:
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.entity(**obj_in_data)
        exists = self.check_conflict(db, entity=db_obj)
        if exists:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="User Already Exists!",
                    status_code=409,
                )
            )
            return None

        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)

        qr_code_data = generate_qr_code(db_obj.id)
        new_user_profile = UserProfileModel(
            user_id=db_obj.id, qr_code=qr_code_data)
        user = context_actor_user_data.get()
        db.add(new_user_profile)

        if obj_in.role == UserRoleSchema.EMPLOYEE:
            employee = EmployeeModel(user_id=db_obj.id, manager_id=db_obj.id)
            if user:
                employee.manager_id = user.id
            db.add(employee)
            new_cv = CVModel(
                user_id=db_obj.id,
                english_full_name=f"{db_obj.first_name} {db_obj.last_name}",
                email=db_obj.email,
                phone_number=db_obj.phone_number,
            )
            db.add(new_cv)

        db.commit()

        # ✅ Send confirmation email after user is fully created
        try:
            # Admin notification
            admin_email = "ejtiazportal@gmail.com"
            subject_admin = "New User Registration Notification"
            body_admin = (
                f"Our new client {db_obj.first_name} with role {db_obj.role} "
                f"has registered and would like your approval.\n\n"
                f"Click the link below to review:\nhttps://marrir.com/\n\n"
                "Thanks!"
            )
            send_emails(to_email=admin_email,
                        subject=subject_admin, body=body_admin)

            # User welcome email
            user_email = db_obj.email  # ✅ send to the user's registered email
            subject_user = "Welcome to Marri Platform!"
            body_user = (
                f"Welcome to Marri, {db_obj.first_name}!\n\n"
                "Please visit our platform and download + submit the Business Agreement.\n\n"
                "You can log in and get started here: https://marrir.com/\n\n"
                "Your account has been created successfully.\n\nThanks!"
            )
            send_emails(to_email=user_email,
                        subject=subject_user, body=body_user)

        except Exception as e:
            # Optionally log this error
            print(f"Failed to send email: {e}")

        if db_obj is not None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} created successfully",
                    status_code=201,
                )
            )

        return db_obj

    def update(
        self,
        db: Session,
        filter_obj_in: FilterSchemaType,
        obj_in: Union[UpdateSchemaType, Dict[str, Any]],
    ) -> Optional[EntityType]:
        entity = self.get(db, filter_obj_in)

        if entity is None or not self.is_allowed_or_is_owner(
            entity, RBACAccessType.update
        ):
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found or not authorized to update",
                    status_code=404,
                )
            )
            return None

        update_data = (
            obj_in if isinstance(obj_in, dict) else obj_in.dict(
                exclude_unset=True)
        )

        if "email" in update_data or "phone_number" in update_data:
            existing_user = (
                db.query(self.entity)
                .filter(
                    or_(
                        self.entity.email == update_data.get("email"),
                        self.entity.phone_number == update_data.get(
                            "phone_number"),
                    ),
                    self.entity.id != entity.id,
                )
                .first()
            )

            if existing_user:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message="Email or phone number already exists.",
                        status_code=400,
                    )
                )
                return None

        for key, value in update_data.items():
            setattr(entity, key, value)

        db.commit()
        db.refresh(entity)

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{self.entity.get_resource_name(self.entity.__name__)} updated successfully",
                status_code=200,
            )
        )

        return entity

    def updateTerms(
        self,
        db: Session,
        filter_obj_in: FilterSchemaType,
        obj_in: Union[UpdateSchemaType, Dict[str, Any]],
    ) -> Optional[EntityType]:
        entity = self.get(db, filter_obj_in)

        if entity is None or not self.is_allowed_or_is_owner(entity, RBACAccessType.update):
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found or not authorized to update",
                    status_code=404,
                )
            )
            return None

        update_data = (
            obj_in if isinstance(obj_in, dict) else obj_in.dict(
                exclude_unset=True)
        )

        for key, value in update_data.items():
            setattr(entity, key, value)

        try:
            db.commit()  # Commit the transaction
            db.refresh(entity)  # Refresh the entity to get the updated values
        except Exception as e:
            db.rollback()  # Rollback in case of error
            raise Exception(f"Error during database update: {str(e)}")

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{self.entity.get_resource_name(self.entity.__name__)} updated successfully",
                status_code=200,
            )
        )

        return entity

    def delete(self, db: Session, filters: FilterSchemaType) -> EntityType:
        return super().delete(db, filters)

    def soft_delete(self, db: Session, filters: FilterSchemaType) -> EntityType:
        return super().soft_delete(db, filters)

    def filter(self, db: Session, *expressions: BinaryExpression) -> list[EntityType]:
        return super().filter(db, *expressions)

    def bulk_upload(self, db: Session, *, file: UploadFile = File(...)):
        try:
            valid, emails, phones = [], set(), set()

            # ✅ Read excel file safely
            contents = file.file.read()   # Read uploaded file as bytes
            df = pd.read_excel(io.BytesIO(contents), dtype={
                               "passport_number": str, "phone_number": str})
            df = df.map(lambda x: None if pd.isna(x) or x == "" else x)

            for index, row in df.iterrows():
                entity = row.to_dict()

                # ✅ Replace NaN with None
                for key, value in entity.items():
                    if pd.isna(value):
                        entity[key] = None

                # ✅ Ensure phone_number is string
                if entity.get("phone_number") is not None:
                    entity["phone_number"] = str(entity["phone_number"])

                # ✅ Split english_full_name into first_name and last_name
                full_name = entity.get("english_full_name", "")
                if full_name and isinstance(full_name, str):
                    parts = full_name.strip().split(" ", 1)
                    entity["first_name"] = self.capitalize_string(
                        parts[0]) if parts else None
                    entity["last_name"] = self.capitalize_string(
                        parts[1]) if len(parts) > 1 else None
                else:
                    entity["first_name"], entity["last_name"] = None, None

                # ✅ Normalize other fields
                entity["date_of_birth"] = (
                    pd.to_datetime(entity.get("date_of_birth"),
                                   errors="coerce").date()
                    if entity.get("date_of_birth")
                    else None
                )
                entity["passport_number"] = str(entity.get(
                    "passport_number")) if entity.get("passport_number") else None
                entity["nationality"] = self.capitalize_string(entity.get(
                    "nationality")) if entity.get("nationality") else None

                # ✅ Build User schema

                # ✅ Build User schema
                obj_in = UserCreateSchema(**entity)

                # Remove keys that UserModel doesn’t support
                user_data = obj_in.dict(exclude={"english_full_name"})

                # Create DB object
                db_obj = self.entity(**user_data)

                # ✅ Conflict check
                exists = self.check_conflict(db, entity=db_obj)
                if exists or db_obj.email in emails or db_obj.phone_number in phones:
                    context_set_response_code_message.set(
                        BaseGenericResponse(
                            error=True,
                            message=f"User with Email Address: {db_obj.email} or Phone Number: {db_obj.phone_number} already exists!",
                            status_code=409,
                        )
                    )
                    return

                valid.append(db_obj)
                emails.add(db_obj.email)
                phones.add(db_obj.phone_number)

            # ✅ Persist users + related models
            for db_obj in valid:
                db.add(db_obj)
                db.flush()

                qr_code_data = generate_qr_code(db_obj.id)
                new_user_profile = UserProfileModel(
                    user_id=db_obj.id, qr_code=qr_code_data
                )
                user_id = context_actor_user_data.get().id

                db.add(new_user_profile)

                employee = EmployeeModel(
                    user_id=db_obj.id,
                    manager_id=user_id,
                )
                db.add(employee)

                new_cv = CVModel(
                    user_id=db_obj.id,
                    english_full_name=(
                        db_obj.first_name + " " + db_obj.last_name) if db_obj.first_name else None,
                    email=db_obj.email,
                    phone_number=db_obj.phone_number,
                    sex=db_obj.sex,
                    date_of_birth=db_obj.date_of_birth,
                    passport_number=db_obj.passport_number,
                    nationality=db_obj.nationality,
                )
                db.add(new_cv)

            return
        except Exception as e:
            logger.error(f"Error in user bulk_upload: {e}")
            try:
                err = e.errors()[0]
                _input = err.get("input")
                _msg = err.get("msg").replace("value", str(_input))
            except Exception:
                _msg = str(e)

            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=_msg,
                    status_code=400,
                )
            )
            return None

    def check_conflict(self, db: Session, entity: EntityType):
        return super().check_conflict(db, entity)

    def convert_to_model(
        self, obj_in: Generic[EntityType, CreateSchemaType, UpdateSchemaType]
    ) -> EntityType:
        return super().convert_to_model(obj_in)

    def increment_profile_views(self, db: Session, filters: FilterSchemaType):
        user = context_actor_user_data.get()
        profile_view = (
            db.query(ProfileViewModel)
            .filter_by(user_id=filters.id, profile_viewer_id=user.id)
            .first()
        )
        if not profile_view:
            new_view = ProfileViewModel(
                **UserProfileViewSchema(
                    user_id=filters.id, profile_viewer_id=user.id
                ).dict()
            )
            db.add(new_view)
            db.commit()
            db.refresh(new_view)
        return

    def authenticate(
        self, db: Session, user_login: UserLoginSchema
    ) -> Optional[UserTokenResponseSchema]:
        user_filter = UserFilterSchema(
            email=user_login.email, phone_number=user_login.phone_number
        )
        user = self.get(db, user_filter)
        if not user:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="The email or password is incorrect!",
                    status_code=404,
                )
            )
            return None

        if user.is_deleted is True or user.verified is False:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="The email or password is incorrect!",
                    status_code=404,
                )
            )
            return None

        if not verify_password(user_login.password, user.password):
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="The email or password is incorrect!",
                    status_code=404,
                )
            )
            return None
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False, message="successfully logged in", status_code=200
            )
        )
        access_token = encode_user_access_token(
            UserTokenSchema(
                id=user.id,
                email=user.email,
                phone_number=user.phone_number,
                role=user.role,
            )
        )
        refresh_token = encode_user_refresh_token(
            UserTokenSchema(
                id=user.id,
                email=user.email,
                phone_number=user.phone_number,
                role=user.role,
            )
        )
        return UserTokenResponseSchema(
            user_id=user.id,
            email=user.email,
            role=user.role,  # Add this line
            access_token=access_token,
            refresh_token=refresh_token
        )

    def user_handling_logic(self, db: Session, user_info: dict):
        email = user_info.get("email")
        google_id = user_info.get("id")
        first_name = user_info.get("given_name")
        last_name = user_info.get("family_name")

        user = db.query(UserModel).filter(UserModel.email == email).first()
        if not user:
            user_schema = UserCreateSchema(
                email=email,
                first_name=first_name,
                last_name=last_name,
                role=UserRoleSchema.EMPLOYEE,
                password="Password1@",
            )

            new_user = self.create(db=db, obj_in=user_schema)
            new_user.verified = True
            new_user.google_id = google_id
            db.commit()
            db.refresh(new_user)
        elif not user.google_id:
            user.google_id = google_id
            db.commit()

        access_token = encode_user_access_token(
            UserTokenSchema(id=user.id, email=user.email, role=user.role)
        )
        refresh_token = encode_user_refresh_token(
            UserTokenSchema(id=user.id, email=user.email, role=user.role)
        )
        return UserTokenResponseSchema(
            user_id=user.id,
            email=user.email,
            role=user.role.value if isinstance(
                user.role, Enum) else str(user.role),
            access_token=access_token,
            refresh_token=refresh_token,
        )

    def refresh(
        self, access_token: str, refresh_token: str
    ) -> Optional[UserTokenResponseSchema]:
        decoded_access_token = decode_user_access_token(access_token)

        if decoded_access_token is None:
            decoded_refresh_token = decode_user_refresh_token(refresh_token)

            if decoded_refresh_token is None:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=f"refresh token for {self.entity.get_resource_name(self.entity.__name__)} has expired",
                        status_code=401,
                    )
                )
                return None
            else:
                access_token = encode_user_access_token(
                    UserTokenSchema(
                        id=decoded_refresh_token.id,
                        email=decoded_refresh_token.email,
                        phone_number=decoded_refresh_token.phone_number,
                        role=decoded_refresh_token.role,
                    )
                )
                refresh_token = encode_user_refresh_token(
                    UserTokenSchema(
                        id=decoded_refresh_token.id,
                        email=decoded_refresh_token.email,
                        phone_number=decoded_refresh_token.phone_number,
                        role=decoded_refresh_token.role,
                    )
                )
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=False,
                        message=f"tokens refreshed for {self.entity.get_resource_name(self.entity.__name__)}",
                        status_code=200,
                    )
                )
                return UserTokenResponseSchema(
                    access_token=access_token, refresh_token=refresh_token
                )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"access token for {self.entity.get_resource_name(self.entity.__name__)} is not expired",
                    status_code=400,
                )
            )
            return None

    # TODO Needs an actual verification process
    def verify(self, db: Session, filters: FilterSchemaType) -> Optional[EntityType]:
        entity = self.get(db, filters)
        if entity is None or entity.verified is True:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} "
                    f'{"not found" if entity is None else "already verified"}',
                    status_code=404 if entity is None else 400,
                )
            )
            return None
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} verified",
                    status_code=200,
                )
            )
            entity.verified = True
            db.commit()

        return entity

    def disable_enable(self, db: Session, user_id: uuid.UUID) -> Optional[EntityType]:
        entity = db.query(UserModel).filter_by(id=user_id).first()
        if entity is None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=404,
                )
            )
            return None
        entity.disabled = not entity.disabled

        db.commit()

        return entity

    def capitalize_string(self, value):
        if isinstance(value, str):
            return value.capitalize()
        return value
