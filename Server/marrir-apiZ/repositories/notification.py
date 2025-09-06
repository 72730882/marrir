from typing import Any, List
from fastapi.encoders import jsonable_encoder
from sqlalchemy import desc

from core.auth import RBACAccessType
from models.notificationmodel import NotificationModel
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from models.usernotificationmodel import UserNotificationModel

from repositories.base import (
    BaseRepository,
    EntityType,
    FilterSchemaType,
    UpdateSchemaType,
)
from repositories.usernotification import UserNotificationRepository
from schemas.base import BaseGenericResponse
from core.context_vars import context_set_response_code_message, context_actor_user_data
from sqlalchemy.sql.operators import like_op

from schemas.notificationschema import (
    NotificationCreateSchema,
    NotificationReceipentTypeSchema,
    SingleUserNotificationReadSchema,
    TotalNotificationSchema,
    UserNotificationBaseSchema,
)
from models import NotificationReadModel
from core.context_vars import context_actor_user_data


class NotificationRepository(
    BaseRepository[NotificationModel, NotificationCreateSchema, Any]
):
    def get_some(
        self, db: Session, skip: int, limit: int, filters: FilterSchemaType
    ) -> List[EntityType]:
        return super().get_some(db, skip, limit, filters)

    def send(self, db: Session, obj_in: NotificationCreateSchema) -> EntityType | None:
        user_notification_repo = UserNotificationRepository(
            entity=UserNotificationModel
        )

        attributes_to_exclude = ["receipent_ids"]
        obj_in_data = obj_in.model_dump(exclude=attributes_to_exclude)
        new_obj_in_data = jsonable_encoder(obj_in_data)
        db_obj = self.entity(**new_obj_in_data)

        try:
            db.add(db_obj)
            db.commit()
            db.refresh(db_obj)

            if len(obj_in.receipent_ids) != 0:
                for user_id in obj_in.receipent_ids:
                    user_notification = UserNotificationBaseSchema(
                        user_id=str(user_id), notification_id=db_obj.id, is_read=False
                    )
                    try:
                        user_notification_repo.create(db, obj_in=user_notification)
                    except Exception as e:
                        db.rollback()
                        raise e

            if db_obj is not None:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=False,
                        message=f"{self.entity.get_resource_name(self.entity.__name__)} sent successfully",
                        status_code=201,
                    )
                )
            return db_obj

        except Exception as e:
            db.rollback()
            try:
                db.delete(db_obj)
            except SQLAlchemyError:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=False,
                        message=f"{self.entity.get_resource_name(self.entity.__name__)} not sent",
                        status_code=404,
                    )
                )
            raise e

    def mark_notification_as_read(self, db: Session, notification_id: int) -> None:
        user_data = context_actor_user_data.get()
        user_notification = (
            db.query(UserNotificationModel)
            .filter_by(notification_id=notification_id, user_id=user_data.id)
            .first()
        )

        if user_notification:
            user_notification.is_read = True
        else:
            read_notification = (
                db.query(NotificationReadModel)
                .filter_by(notification_id=notification_id, user_id=user_data.id)
                .first()
            )

            if not read_notification:
                new_read_notification = NotificationReadModel(
                    notification_id=notification_id, user_id=user_data.id
                )
                db.add(new_read_notification)

        db.commit()
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"Marked {self.entity.get_resource_name(self.entity.__name__)} as read",
                status_code=204,
            )
        )
        return

    def mark_all_notifications_as_read(self, db: Session):
        user_data = context_actor_user_data.get()
        db.query(UserNotificationModel).filter_by(user_id=user_data.id).update(
            {UserNotificationModel.is_read: True}
        )

        unread_group_notifications = (
            db.query(NotificationModel.id)
            .filter(
                NotificationModel.receipent_type
                != NotificationReceipentTypeSchema.USER,
                NotificationModel.receipent_type
                != NotificationReceipentTypeSchema.NONE,
                ~NotificationModel.notification_reads.any(user_id=user_data.id),
            )
            .all()
        )

        for notification_id in unread_group_notifications:
            new_read_notification = NotificationReadModel(
                notification_id=notification_id[0], user_id=user_data.id
            )
            db.add(new_read_notification)
        db.commit()
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"Marked all {self.entity.get_resource_name(self.entity.__name__)}s as read",
                status_code=204,
            )
        )
        return

    def get_user_notifications(self, db: Session) -> TotalNotificationSchema | None:
        user_data = context_actor_user_data.get()
        entities = []
        unread_count = 0

        user_notifications = (
            db.query(NotificationModel, UserNotificationModel)
            .filter(NotificationModel.id == UserNotificationModel.notification_id)
            .filter(UserNotificationModel.user_id == user_data.id)
            .order_by(desc(NotificationModel.created_at))
            .all()
        )

        group_notifications = (
            db.query(NotificationModel, NotificationReadModel)
            .filter(
                (
                    NotificationModel.receipent_type
                    == NotificationReceipentTypeSchema.ALL
                )
                | (NotificationModel.receipent_type == user_data.role)
            )
            .outerjoin(
                NotificationReadModel,
                (NotificationModel.id == NotificationReadModel.notification_id)
                & (NotificationReadModel.user_id == user_data.id),
            )
            .order_by(desc(NotificationModel.created_at))
            .all()
        )

        for notification, seen_notification in group_notifications:
            notification = SingleUserNotificationReadSchema(
                id=notification.id,
                type=notification.type,
                title=notification.title,
                type_metadata=notification.type_metadata,
                description=notification.description,
                created_at=notification.created_at,
            )

            if seen_notification:
                notification.is_read = True
            else:
                notification.is_read = False
                unread_count += 1
            entities.append(notification)

        for notification, user_notification in user_notifications:
            notification = SingleUserNotificationReadSchema(
                id=notification.id,
                type=notification.type,
                title=notification.title,
                type_metadata=notification.type_metadata,
                description=notification.description,
                is_read=user_notification.is_read,
                created_at=notification.created_at,
            )
            if not user_notification.is_read:
                unread_count += 1

            entities.append(notification)

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s not found / not found in the "
                    f"page specified",
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
                    count=len(entities),
                )
            )

        return TotalNotificationSchema(
            notifications=entities, unread_count=unread_count
        )
