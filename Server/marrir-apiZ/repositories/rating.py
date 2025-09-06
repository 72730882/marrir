import datetime
from typing import Any, Dict, Optional, Union, Generic, List
from fastapi.encoders import jsonable_encoder

from sqlalchemy import BinaryExpression
from sqlalchemy.orm import Session
from core.auth import RBACAccessType

from core.context_vars import context_set_response_code_message, context_actor_user_data
from models.cvmodel import CVModel
from models.employeemodel import EmployeeModel
from models.paymentmodel import PaymentModel
from models.ratingmodel import RatingModel
from models.usermodel import UserModel
from repositories.base import (
    BaseRepository,
    EntityType,
    FilterSchemaType,
    UpdateSchemaType,
)
from schemas.base import BaseGenericResponse
from schemas.ratingschema import (
    EmployeeRatingFilterSchema,
    RatingCreateSchema,
    RatingFilterSchema,
    RatingTypeSchema,
    RatingUpdateSchema,
    UserRatingSchema,
)
from schemas.userschema import EmployeeRatingSchema, UserRoleSchema


class RatingRepository(
    BaseRepository[RatingModel, RatingCreateSchema, RatingUpdateSchema]
):
    def get_my_employees_ratings(
        self, db: Session, filters: EmployeeRatingFilterSchema
    ) -> List[EntityType]:
        employee_ids = (
            db.query(EmployeeModel.user_id)
            .filter(EmployeeModel.manager_id == filters.manager_id)
            .all()
        )
        employee_ids = [id[0] for id in employee_ids]
        ratings: List[EmployeeRatingSchema] = []

        for employee_id in employee_ids:
            admin_rating = (
                db.query(RatingModel.value)
                .filter(
                    RatingModel.user_id == employee_id,
                    RatingModel.type == RatingTypeSchema.ADMIN,
                )
                .all()
            )

            test_rating = (
                db.query(RatingModel.value)
                .filter(
                    RatingModel.user_id == employee_id,
                    RatingModel.type == RatingTypeSchema.TEST,
                )
                .all()
            )

            sponsor_rating = (
                db.query(RatingModel.value)
                .filter(
                    RatingModel.user_id == employee_id,
                    RatingModel.type == RatingTypeSchema.SPONSOR,
                )
                .all()
            )

            admin_rating_values = [rating.value for rating in admin_rating]
            test_rating_values = [rating.value for rating in test_rating]
            sponsor_rating_values = [rating.value for rating in sponsor_rating]

            employee = db.query(CVModel).filter_by(user_id=employee_id).first()
            user_name = (
                db.query(UserModel.first_name, UserModel.last_name)
                .filter_by(id=employee_id)
                .first()
            )
            full_name = f"{user_name[0]} {user_name[1]}" if user_name else None

            employee_rating = EmployeeRatingSchema(
                user_id=employee_id,
                user_name=full_name,
                user=employee,
                ratings=UserRatingSchema(
                    admin_rating=sum(admin_rating_values)
                    / max(1, len(admin_rating_values)),
                    self_rating=sum(test_rating_values)
                    / max(1, len(test_rating_values)),
                    sponsor_rating=sum(sponsor_rating_values)
                    / max(1, len(sponsor_rating_values)),
                ),
            )

            ratings.append(employee_rating)
        return ratings

    def get_user_ratings(
        self, db: Session, filters: RatingFilterSchema
    ) -> List[EntityType]:
        admin_rating = (
            db.query(RatingModel.value)
            .filter(
                RatingModel.user_id == filters.user_id,
                RatingModel.type == RatingTypeSchema.ADMIN,
            )
            .all()
        )

        test_rating = (
            db.query(RatingModel.value)
            .filter(
                RatingModel.user_id == filters.user_id,
                RatingModel.type == RatingTypeSchema.TEST,
            )
            .all()
        )

        sponsor_rating = (
            db.query(RatingModel.value)
            .filter(
                RatingModel.user_id == filters.user_id,
                RatingModel.type == RatingTypeSchema.SPONSOR,
            )
            .all()
        )

        admin_rating_values = [rating.value for rating in admin_rating]
        test_rating_values = [rating.value for rating in test_rating]
        sponsor_rating_values = [rating.value for rating in sponsor_rating]

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{self.entity.get_resource_name(self.entity.__name__)} of {filters.user_id} found",
                status_code=200,
            )
        )

        return UserRatingSchema(
            admin_rating=sum(admin_rating_values) / max(1, len(admin_rating_values)),
            self_rating=sum(test_rating_values) / max(1, len(test_rating_values)),
            sponsor_rating=sum(sponsor_rating_values)
            / max(1, len(sponsor_rating_values)),
        )

    def add_rating(
        self, db: Session, *, obj_in: RatingCreateSchema
    ) -> EntityType | None:
        rating = (
            db.query(RatingModel)
            .filter(RatingModel.user_id == obj_in.user_id)
            .filter(RatingModel.rated_by == obj_in.rated_by)
            .first()
        )
        if rating:
            rating.value = obj_in.value
            db.commit()
            return rating
        else:
            user = context_actor_user_data.get()
            if (
                user.role == UserRoleSchema.RECRUITMENT
                or user.role == UserRoleSchema.SPONSOR
            ):
                obj_in.type = RatingTypeSchema.SPONSOR
            elif user.role == UserRoleSchema.ADMIN:
                obj_in.type = RatingTypeSchema.ADMIN
            else:
                obj_in.type = RatingTypeSchema.TEST
            obj_in.rated_by = user.id

            obj_in_data = jsonable_encoder(obj_in)
            db_obj = self.entity(**obj_in_data)
            db.add(db_obj)
            db.commit()
            db.refresh(db_obj)

            if db_obj is not None:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=False,
                        message=f"{self.entity.get_resource_name(self.entity.__name__)} added successfully",
                        status_code=201,
                    )
                )
            return db_obj

    def update_rating(
        self,
        db: Session,
        filter_obj_in: FilterSchemaType,
        obj_in: Union[UpdateSchemaType, Dict[str, Any]],
    ) -> EntityType:
        return super().update(db, filter_obj_in=filter_obj_in, obj_in=obj_in)

    def remove_rating(self, db: Session, filters: FilterSchemaType) -> EntityType:
        return super().delete(db, filters=filters)
