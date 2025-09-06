import datetime
from typing import Any, Dict, Optional, Union, Generic, List
from fastapi.encoders import jsonable_encoder

from sqlalchemy import BinaryExpression, column, update
from sqlalchemy.orm import Session
from core.auth import RBACAccessType

from core.context_vars import context_set_response_code_message, context_actor_user_data
from models.jobapplicationmodel import JobApplicationModel
from models.jobmodel import JobModel
from models.notificationmodel import NotificationModel
from models.paymentmodel import PaymentModel
from models.offermodel import OfferModel
from repositories.base import (
    BaseRepository,
    EntityType,
    FilterSchemaType,
    UpdateSchemaType,
)
from repositories.jobapplication import JobApplicationRepository
from repositories.notification import NotificationRepository
from repositories.payment import PaymentRepository
from schemas.base import BaseGenericResponse
from schemas.notificationschema import NotificationCreateSchema, NotificationReceipentTypeSchema, NotificationTypeSchema
from schemas.paymentschema import PaymentFilterSchema
from schemas.offerschema import (
    OfferCreateSchema,
    OfferTypeSchema,
    OfferUpdateSchema,
    OfferFilterSchema,
)


class OfferRepository(BaseRepository[OfferModel, OfferCreateSchema, OfferUpdateSchema]):
    def view_offers(
        self,
        db: Session,
        skip: int,
        limit: int,
        search: Optional[str],
        search_schema: Optional[any],
        start_date: Optional[str],
        end_date: Optional[str],
        filters: FilterSchemaType,
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
)

    def send_offer(self, db: Session, obj_in: OfferCreateSchema) -> EntityType:
        obj_in.sponsor_id = context_actor_user_data.get().id
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.entity(**obj_in_data)
        exists = self.check_conflict(db, entity=db_obj)
        if exists:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"conflict occurred trying to create {self.entity.get_resource_name(self.entity.__name__)}",
                    status_code=409,
                )
            )
            return None

        job_application = (
            db.query(JobApplicationModel)
            .filter_by(job_id=obj_in.job_id, user_id=obj_in.receiver_id)
            .first()
        )

        job = db.query(JobModel).filter_by(id=job_application.job_id).first()
        job_application.status = OfferTypeSchema.ACCEPTED
        notification_repo = NotificationRepository(NotificationModel)
        notification = NotificationCreateSchema(
            receipent_ids=[obj_in.receiver_id],
            description=f"Cogratulations! Your application for {job.name} has been accepted. We would like to forward our offer. Do you wish to accept this offer?",
            title="Application Accepted!",
            receipent_type=NotificationReceipentTypeSchema.NONE,
            type=NotificationTypeSchema.OFFER,
            type_metadata=f'{job_application.job_id}'
        )
        notification_repo.send(db, notification)

        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        db.refresh(job_application)

        if db_obj is not None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} sent successfully",
                    status_code=201,
                )
            )
            
        return db_obj

    def accept_decline_offer(
        self,
        db: Session,
        filter_obj_in: FilterSchemaType,
        obj_in: Union[UpdateSchemaType, Dict[str, Any]],
    ) -> EntityType:
        query = update(self.entity)

        entity = self.get(db, filter_obj_in)

        can_not_update = (
            self.is_allowed_or_is_owner(
                entity=entity, access_type=RBACAccessType.update
            )
            is False
        )

        if entity is None or can_not_update:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found while trying to update",
                    status_code=404,
                )
            )
            return None

        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.dict(exclude_unset=True)

        if update_data['offer_status'] == OfferTypeSchema.ACCEPTED:
            notification_repo = NotificationRepository(NotificationModel)
            notification = NotificationCreateSchema(
                receipent_ids=[entity.receiver_id],
                description="You have to pay 300 ETB to continue the process",
                title="Payment Required",
                receipent_type=NotificationReceipentTypeSchema.NONE,
                type=NotificationTypeSchema.SUCCESS 
            )
            notification_repo.send(db, notification)

        filter_obj_data = jsonable_encoder(filter_obj_in)
        for field in filter_obj_data:
            if filter_obj_data[field] is not None:
                query = query.where(column(field) == filter_obj_data[field])

        query = query.values(update_data).returning("*")

        result = db.execute(query).all()

        if len(result) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"Failed to update {self.entity.get_resource_name(self.entity.__name__)}",
                    status_code=500,
                )
            )

            return None
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} updated successfully",
                    status_code=200,
                )
            )
            db.refresh(entity)
            return entity

            
    def rescind_offer(self, db: Session, filters: FilterSchemaType) -> EntityType:
        entity = self.get(db, filters)

        if entity is None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} Not Found",
                    status_code=404,
                )
            )
            return None
        else:
            job_application = db.query(JobApplicationModel).filter_by(job_id=entity.job_id, id=entity.receiver_id).first()
            if job_application:
                job_application.status = OfferTypeSchema.PENDING
            notification_repo = NotificationRepository(NotificationModel)
            notification = NotificationCreateSchema(
                receipent_ids=[entity.receiver_id],
                description="Offer was rescinded",
                title="Offer Rescinded",
                receipent_type=NotificationReceipentTypeSchema.NONE,
                type=NotificationTypeSchema.FAILURE 
            )
            notification_repo.send(db, notification)

            db.delete(entity)
            db.commit()
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} deleted successfully",
                    status_code=200,
                )
            )
            return entity
