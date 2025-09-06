from typing import Any, Dict, List, Optional, Union
from fastapi.encoders import jsonable_encoder
from sqlalchemy import column, update
from core.auth import RBACAccessType
from core.context_vars import context_set_response_code_message, context_actor_user_data
from sqlalchemy.orm import Session
from models.assignagentmodel import AssignAgentModel

from models.notificationmodel import NotificationModel
from models.startedagentprocessmodel import StartedAgentProcessModel
from models.usermodel import UserModel
from repositories.base import (
    BaseRepository,
    EntityType,
    FilterSchemaType,
    UpdateSchemaType,
)
from repositories.notification import NotificationRepository
from schemas.assignagentschema import (
    AssignAgentCreateSchema,
    AssignAgentFilterSchema,
    AssignAgentUpdateSchema,
    StartedAgentProcessCreateSchema,
)
from schemas.base import BaseGenericResponse
from schemas.enumschema import (
    NotificationReceipentTypeSchema,
    NotificationTypeSchema,
    TransferStatusSchema,
    UserRoleSchema,
)
from schemas.notificationschema import NotificationCreateSchema


class AssignAgentRepository(
    BaseRepository[
        AssignAgentModel,
        AssignAgentCreateSchema,
        AssignAgentUpdateSchema,
    ]
):
    def create(
        self, db: Session, *, obj_in: AssignAgentCreateSchema
    ) -> EntityType | None:
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.entity(**obj_in_data)

        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)

        requester = db.query(UserModel).filter_by(id=obj_in.requester_id).first()
        requester_name = (
            requester.company.company_name
            if requester.company
            else requester.first_name + " " + requester.last_name
        )

        employee = db.query(UserModel).filter_by(id=obj_in.user_id).first()
        employee_name = (
            employee.cv.english_full_name
            if employee.cv and employee.cv.english_full_name
            else (
                employee.first_name + " " + employee.last_name
                if employee.first_name and employee.last_name
                else "N/A"
            )
        )

        notification_repo = NotificationRepository(NotificationModel)
        notification = NotificationCreateSchema(
            receipent_ids=[obj_in.agent_id],
            description=f"You have received process request from {requester_name} to process employee {employee_name}.",
            title="Agent Assignment Request",
            receipent_type=NotificationReceipentTypeSchema.NONE,
            type=NotificationTypeSchema.AGENT_ASSIGNMENT,
        )
        notification_repo.send(db, notification)

        if db_obj is not None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message="Agent assign request created successfully",
                    status_code=201,
                )
            )

        return db_obj

    def agent_create(self, db: Session, *, obj_in: StartedAgentProcessCreateSchema):
        user = context_actor_user_data.get()
        if user.role == UserRoleSchema.AGENT:
            started_process = StartedAgentProcessModel(
                user_id=obj_in.user_id, agent_id=user.id
            )
            db.add(started_process)
            db.commit()
            db.refresh(started_process)

            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message="Process started successfully",
                    status_code=201,
                )
            )

            return started_process
        return

    def accept_or_decline_assign_request(
        self,
        db: Session,
        filter_obj_in: FilterSchemaType,
        obj_in: Union[UpdateSchemaType, Dict[str, Any]],
    ):
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

        notification_repo = NotificationRepository(NotificationModel)
        agent_name = (
            entity.agent.company.company_name
            if entity.agent.company
            else entity.agent.first_name + " " + entity.agent.last_name
        )
        employee_name = (
            entity.user.cv.english_full_name
            if entity.user.cv and entity.user.cv.english_full_name
            else entity.user.first_name + " " + entity.user.last_name
        )

        if update_data["status"] == TransferStatusSchema.ACCEPTED:
            notification = NotificationCreateSchema(
                receipent_ids=[entity.requester_id],
                description=f"Your request to assign agent {agent_name} to process employee {employee_name} has been accepted. You can proceed to pay.",
                title="Agent Assignment Successful",
                receipent_type=NotificationReceipentTypeSchema.NONE,
                type=NotificationTypeSchema.SUCCESS,
            )
            notification_repo.send(db, notification)
        elif update_data["status"] == TransferStatusSchema.DECLINED:
            reason = update_data["reason"]
            notification = NotificationCreateSchema(
                receipent_ids=[entity.requester_id],
                description=f"Your request to assign agent {agent_name} to process employee {employee_name} has been declined. Reason: {reason}",
                title="Agent Assignment Unsuccessful",
                receipent_type=NotificationReceipentTypeSchema.NONE,
                type=NotificationTypeSchema.FAILURE,
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
                    message=f"Agent assignment updated successfully",
                    status_code=200,
                )
            )
            db.refresh(entity)
            return entity

    def get_agent_assign_requests_received(
        self,
        db: Session,
        skip: int,
        limit: int,
        filters: Optional[AssignAgentFilterSchema] = None,
    ):
        user = context_actor_user_data.get()
        query = db.query(AssignAgentModel).filter_by(agent_id=user.id)
        total_count = query.count()

        if filters:
            filters_conditions = self.build_filters(
                AssignAgentModel, filters.__dict__ if filters else {}
            )

            query = query.filter(filters_conditions)

        entities = query.offset(skip).limit(limit).all()

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"Agent assignment requests not found / not found in the ",
                    status_code=404,
                )
            )
        elif len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No agent assignment requests received",
                    status_code=200,
                    count=0,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"Agent assignment requests found",
                    status_code=200,
                    count=total_count,
                )
            )
        return entities

    def get_agent_processes(
        self,
        db: Session,
        skip: int,
        limit: int,
    ):
        user = context_actor_user_data.get()
        query = db.query(StartedAgentProcessModel).filter_by(agent_id=user.id)
        total_count = query.count()

        entities = query.offset(skip).limit(limit).all()

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"Agent assignment requests not found / not found in the ",
                    status_code=404,
                )
            )
        elif len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No agent assignment requests received",
                    status_code=200,
                    count=0,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"Agent assignment requests found",
                    status_code=200,
                    count=total_count,
                )
            )
        return entities

    def get_agent_assign_requests_sent(
        self,
        db: Session,
        skip: int,
        limit: int,
        filters: AssignAgentFilterSchema,
    ) -> List[EntityType]:
        query = db.query(AssignAgentModel).filter_by(requester_id=filters.requester_id)
        total_count = query.count()

        entities = query.offset(skip).limit(limit).all()

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"Agent assignment requests not found / not found in the ",
                    status_code=404,
                )
            )
        elif len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No agent assignment requests sent",
                    status_code=200,
                    count=0,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"Agent assignment requests found",
                    status_code=200,
                    count=total_count,
                )
            )
        return entities
