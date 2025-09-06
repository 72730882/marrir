import datetime
from typing import Any, Dict, Optional, Union, Generic, List
from fastapi.encoders import jsonable_encoder

from sqlalchemy import BinaryExpression, and_
from sqlalchemy.orm import Session
from core.auth import RBACAccessType

from core.context_vars import context_set_response_code_message, context_actor_user_data
from models.cvmodel import CVModel
from models.employeemodel import EmployeeModel
from models.notificationmodel import NotificationModel
from models.paymentmodel import PaymentModel
from models.promotionmodel import PromotionModel, PromotionPackagesModel
from models.usermodel import UserModel
from repositories.base import (
    BaseRepository,
    EntityType,
    FilterSchemaType,
)
from repositories.notification import NotificationRepository
from repositories.payment import PaymentRepository
from schemas.base import BaseGenericResponse
from schemas.enumschema import NotificationReceipentTypeSchema, NotificationTypeSchema
from schemas.notificationschema import NotificationCreateSchema
from schemas.paymentschema import PaymentFilterSchema
from schemas.promotionschema import (
    PromotionCreateSchema,
    PromotionFilterSchema,
    PromotionStatusSchema,
    SinglePromotionCreateSchema,
    PromotionPackageCreateSchema,
)
from schemas.reserveschema import ReserveCVFilterSchema  # Add this import
from sqlalchemy.orm import joinedload


class PromotionRepository(
    BaseRepository[PromotionModel, PromotionCreateSchema, PromotionCreateSchema]
):
    # ...existing methods...

    def get_all_promotions(self, db: Session, skip: int, limit: int):
        query = db.query(PromotionModel)

        total_count = query.count()
        promotions = query.offset(skip).limit(limit).all()
        if len(promotions) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No {self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                    count=0,
                )
            )
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{self.entity.get_resource_name(self.entity.__name__)}s found",
                status_code=200,
                count=total_count,
            )
        )

        return promotions
    '''    
    def get_all_promotions_filter(self, db: Session, skip: int, limit: int):
        query = db.query(PromotionModel).options(joinedload(PromotionModel.promoted_by))
        total_count = query.count()
        promotions = query.offset(skip).limit(limit).all()

        return {
            "data": [
                {
                    **promotion.__dict__,
                    "promoter": {
                            "id": promotion.promoted_by.id,
                            "full_name": f"{promotion.promoted_by.first_name or ''} {promotion.promoted_by.last_name or ''}".strip(),
                            "email": promotion.promoted_by.email,
                            "phone_number": promotion.promoted_by.phone_number,
                            "role": promotion.promoted_by.role,
                        }
                }
                for promotion in promotions
            ],
            "count": total_count
        }
    '''
    def get_all_promotions_filter(self, db: Session, skip: int, limit: int):
        # Join PromotionModel with UserModel and filter by role='employee'
        query = (
            db.query(PromotionModel)
            .join(PromotionModel.promoted_by)
            .options(joinedload(PromotionModel.promoted_by))
           # .filter(UserModel.role.in_(["employee", "selfsponsor"]))
        )
        total_count = query.count()
        promotions = query.offset(skip).limit(limit).all()
        return {
            "data": [
                {
                    **promotion.__dict__,
                    "promoter": {
                        "id": promotion.promoted_by.id,
                        "full_name": f"{promotion.promoted_by.first_name or ''} {promotion.promoted_by.last_name or ''}".strip(),
                        "email": promotion.promoted_by.email,
                        "phone_number": promotion.promoted_by.phone_number,
                        "role": promotion.promoted_by.role,
                    }
                }
                for promotion in promotions
            ],
            "count": total_count
        }

    def promotion_history(
        self, db: Session, skip: int, limit: int, filters: PromotionFilterSchema
    ):
        query = db.query(PromotionModel)

        query = query.filter_by(user_id=filters.user_id)

        total_count = query.count()
        promotions = query.offset(skip).limit(limit).all()
        if len(promotions) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No {self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                    count=0,
                )
            )
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{self.entity.get_resource_name(self.entity.__name__)}s found",
                status_code=200,
                count=total_count,
            )
        )

        return promotions

    def cancel_promotion(self, db: Session, filter: PromotionFilterSchema):
        active_promotion = (
            db.query(PromotionModel)
            .filter_by(user_id=filter.user_id, status=PromotionStatusSchema.ACTIVE)
            .first()
        )
        if active_promotion:
            active_promotion.status = PromotionStatusSchema.CANCELLED
            return active_promotion
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"There is no active promotion!",
                    status_code=400,
                )
            )
            return

    def activate_promotion(self, db: Session, obj_in: PromotionCreateSchema):
        logged_in_user = context_actor_user_data.get()
        notification_repo = NotificationRepository(NotificationModel)
        promotions = []
        for user_id in obj_in.user_ids:
            active_promotion = (
                db.query(PromotionModel)
                .filter_by(user_id=user_id, status=PromotionStatusSchema.ACTIVE)
                .first()
            )
            user = db.query(UserModel).filter_by(id=user_id).first()
            if not user:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=f"User doesn't exist!",
                        status_code=400,
                    )
                )
                return []

            if active_promotion:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=f"There is an already ongoing promotion subscription for {user.first_name} {user.last_name}!",
                        status_code=400,
                    )
                )
                return []

            single_promotion = SinglePromotionCreateSchema(
                user_id=user_id, package=obj_in.package
            )
            obj_in_data = jsonable_encoder(single_promotion)
            db_obj = self.entity(**obj_in_data)
            db.add(db_obj)
            db.commit()
            db.refresh(db_obj)
            subscriber = (
                user.cv.english_full_name
                if user.cv
                else user.first_name + " " + user.last_name
            )
            notification = NotificationCreateSchema(
                receipent_ids=[logged_in_user.id],
                description=f"{subscriber} have successfully subscribed to a {obj_in.package.split('_')[0]} month(s) package",
                title="Subscription Alert",
                receipent_type=NotificationReceipentTypeSchema.NONE,
                type=NotificationTypeSchema.SUCCESS,
            )
            notification_repo.send(db, notification)

            promotions.append(db_obj)
        return promotions

    def get_filtered_employee_cvs(
        self,
        db: Session,
        skip: int,
        limit: int,
        search: Optional[str],
        search_schema: Optional[any],
        filters: Optional[ReserveCVFilterSchema] = None,
    ):
        user = context_actor_user_data.get()
        employee_ids = (
            db.query(EmployeeModel.user_id)
            .filter(EmployeeModel.manager_id == user.id)
            .all()
        )
        employee_ids = [id[0] for id in employee_ids]

        query = db.query(CVModel).filter(CVModel.user_id.in_(employee_ids))

        if search:
            search_filter = self.build_generic_search_filter(
                CVModel, search_schema, search
            )
            if search_filter is not None:
                query = query.filter(search_filter)

        filters_conditions = self.custom_cv_filter(
            CVModel, filters.__dict__ if filters else {}
        )

        query = query.filter(filters_conditions)
        total_count = query.count()
        cv_info = query.offset(skip).limit(limit).all()
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"Users CV found",
                status_code=200,
                count=total_count,
            )
        )
        return cv_info

    def custom_cv_filter(self, model, filters_dict):
        conditions = []

        for key, value in filters_dict.items():
            if (
                value is not None
                and not key.startswith("min_")
                and not key.startswith("max_")
                and key not in ["nationality", "occupation"]
            ):
                field = getattr(model, key, None)
                if field is not None:
                    conditions.append(field == value)

        array_filters = ["nationality", "occupation"]

        for key in array_filters:
            values = filters_dict.get(key)
            if values:
                model_field = getattr(model, key, None)
                if model_field is not None and values:
                    conditions.append(model_field.in_(values))

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

        return and_(*conditions)


