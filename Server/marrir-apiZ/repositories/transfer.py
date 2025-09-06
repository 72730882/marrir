import datetime
from operator import or_
from typing import Any, Dict, Optional, Union, Generic, List
from fastapi.encoders import jsonable_encoder

from sqlalchemy import BinaryExpression, and_, column
from sqlalchemy.orm import Session
from core.auth import RBACAccessType

from core.context_vars import context_set_response_code_message, context_actor_user_data
from models.batchtransfermodel import BatchTransferModel
from models.cvmodel import CVModel
from models.employeemodel import EmployeeModel
from models.notificationmodel import NotificationModel
from models.paymentmodel import PaymentModel
from models.transfermodel import TransferModel
from models.transferrequestmodel import TransferRequestModel
from models.usermodel import UserModel
from repositories.base import (
    BaseRepository,
    EntityType,
    FilterSchemaType,
    UpdateSchemaType,
)
from repositories.notification import NotificationRepository
from repositories.payment import PaymentRepository
from schemas.base import BaseGenericResponse
from schemas.notificationschema import (
    NotificationCreateSchema,
    NotificationReceipentTypeSchema,
    NotificationTypeSchema,
)
from schemas.paymentschema import PaymentFilterSchema
from schemas.reserveschema import ReserveCVFilterSchema
from schemas.transferschema import (
    MultipleTransferRequestFilterSchema,
    TransferCreateSchema,
    TransferFilterSchema,
    TransferRequestBaseSchema,
    TransferRequestCreateSchema,
    TransferRequestFilterSchema,
    TransferUpdatePayload,
    TransferUpdateSchema,
    TransferStatusSchema,
)


class TransferRepository(
    BaseRepository[TransferModel, TransferCreateSchema, TransferUpdateSchema]
):
    def get_my_transfer_requests(
          self,
        db: Session,
        skip: int,
        limit: int,
    ) -> List[EntityType]:
        user = context_actor_user_data.get()
        query = db.query(BatchTransferModel).filter_by(receiver_id=user.id)
        total_count = query.count()
        entities = query.offset(skip).limit(limit).all()

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(TransferRequestModel.__name__)}s not found / not found in the ",
                    status_code=404,
                )
            )
        elif len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No {self.entity.get_resource_name(TransferRequestModel.__name__)}s found",
                    status_code=200,
                    count=0,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(TransferRequestModel.__name__)}s found",
                    status_code=200,
                    count=total_count,
                )
            )
        return entities

    def get_my_transfer_request_details(
        self,
        db: Session,
        skip: int,
        limit: int,
        batch_transfer_id: int,
        search: Optional[str],
        search_schema: Optional[any],
        filters: Optional[ReserveCVFilterSchema] = None,
    ) -> List[EntityType]:
        query = (
            db.query(TransferRequestModel)
            .join(EmployeeModel, TransferRequestModel.user_id == EmployeeModel.user_id)
            .join(CVModel, TransferRequestModel.user_id == CVModel.user_id)
            .filter(TransferRequestModel.batch_id == batch_transfer_id)
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

        query = query.filter(filters_conditions)
        total_count = query.count()

        entities = query.offset(skip).limit(limit).all()

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{self.entity.get_resource_name(TransferRequestModel.__name__)}s found",
                status_code=200,
                count=total_count,
            )
        )
        return entities

    def get_transfer_requests_sent(
        self,
        db: Session,
        skip: int,
        limit: int,
        filters: FilterSchemaType,
    ) -> List[EntityType]:
        query = db.query(BatchTransferModel).filter_by(
            requester_id=filters.requester_id
        )
        total_count = query.count()
        entities = query.offset(skip).limit(limit).all()

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(TransferRequestModel.__name__)}s not found / not found in the ",
                    status_code=404,
                )
            )
        elif len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No {self.entity.get_resource_name(TransferRequestModel.__name__)}s found",
                    status_code=200,
                    count=0,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(TransferRequestModel.__name__)}s found",
                    status_code=200,
                    count=total_count,
                )
            )
        return entities

    def make_transfer(
        self, *, db: Session, obj_in: TransferRequestBaseSchema
    ) -> List[EntityType] | None:
        user = context_actor_user_data.get()
        transfers = []
        receiver_id = obj_in.transfer_receiver_id
        batch_transfer = BatchTransferModel(
            receiver_id=receiver_id, requester_id=user.id
        )
        db.add(batch_transfer)

        for user_id in obj_in.user_ids:
            pending_transfer = (
                db.query(TransferRequestModel)
                .filter(
                    TransferRequestModel.user_id == user_id,
                    TransferRequestModel.manager_id == receiver_id,
                    TransferRequestModel.status == TransferStatusSchema.PENDING,
                )
                .first()
            )

            if pending_transfer:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=f"{self.entity.get_resource_name(self.entity.__name__)} request already ongoing for {user_id}",
                        status_code=400,
                    )
                )
                return []

            single_transfer_request = TransferRequestCreateSchema(
                requester_id=user.id,
                user_id=user_id,
                manager_id=receiver_id,
            )
            obj_in_data = jsonable_encoder(single_transfer_request)
            db_obj = TransferRequestModel(**obj_in_data)
            transfers.append(db_obj)

        db.commit()
        db.refresh(batch_transfer)

        for transfer in transfers:
            transfer.batch_id = batch_transfer.id
            db.add(transfer)
            db.commit()
            db.refresh(transfer)

        notification_repo = NotificationRepository(NotificationModel)
        notification = NotificationCreateSchema(
            receipent_ids=[receiver_id],
            description=f"There has been a transfer request made by {user.email} for {len(transfers)} employee(s). Check the transfer page for more details",
            title="Transfer Request",
            receipent_type=NotificationReceipentTypeSchema.NONE,
            type=NotificationTypeSchema.TRANSFER_REQUEST,
            type_metadata=f"{batch_transfer.id}"
        )
        notification_repo.send(db, notification)

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{self.entity.get_resource_name(self.entity.__name__)} requested for {len(transfers)} employees",
                status_code=200,
            )
        )

        return transfers

    def review_transfer(
        self,
        db: Session,
        filter_obj_in: MultipleTransferRequestFilterSchema,
        obj_in: Union[TransferUpdatePayload, Dict[str, Any]],
    ) -> Optional[EntityType]:
        transfers = []
        for id in filter_obj_in.ids:
            pending_transfer = db.query(TransferRequestModel).filter_by(id=id).first()

            user = (
                db.query(UserModel)
                .filter(UserModel.id == pending_transfer.user_id)
                .first()
            )
            current_transfer = (
                db.query(TransferRequestModel)
                .filter_by(
                    user_id=user.id,
                    status=TransferStatusSchema.ACCEPTED,
                )
                .first()
            )

            if isinstance(obj_in, dict):
                update_data = obj_in
            else:
                update_data = obj_in.dict(exclude_unset=True)

            if update_data["status"] == TransferStatusSchema.ACCEPTED:
                if current_transfer:
                    current_transfer.status = TransferStatusSchema.CANCELLED
                pending_transfer.status = TransferStatusSchema.ACCEPTED
            elif update_data["status"] == TransferStatusSchema.DECLINED:
                pending_transfer.status = TransferStatusSchema.DECLINED
                pending_transfer.reason = update_data["reason"]

            if current_transfer:
                db.commit()
                db.refresh(current_transfer)
            db.commit()
            db.refresh(pending_transfer)

            notification_repo = NotificationRepository(NotificationModel)
            notif_type = (
                NotificationTypeSchema.SUCCESS
                if pending_transfer.status == TransferStatusSchema.ACCEPTED
                else NotificationTypeSchema.FAILURE
            )

            name = ""
            if pending_transfer.user.cv.english_full_name:
                name = pending_transfer.user.cv.english_full_name
            else:
                name = (
                    pending_transfer.user.first_name
                    + " "
                    + pending_transfer.user.last_name
                )
            notification = NotificationCreateSchema(
                receipent_ids=[pending_transfer.requester_id],
                description=f"Your transfer request for employee {name} has been {pending_transfer.status}",
                title="Transfer Request Response",
                receipent_type=NotificationReceipentTypeSchema.NONE,
                type=notif_type,
            )
            notification_repo.send(db, notification)
            transfers.append(pending_transfer)

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{len(transfers)} transfer requests updated successfully",
                status_code=200,
            )
        )

        return transfers
    '''

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

    '''
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
