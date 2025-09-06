import json
from typing import Any, Optional
import uuid
from fastapi import APIRouter, Depends, Response
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db_session
from models.notificationmodel import NotificationModel, Notifications
from models.usermodel import UserModel
from repositories.notification import NotificationRepository
from repositories.user import UserRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message, context_actor_user_data
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.notificationschema import (
    NotificationCreateSchema,
    NotificationReadSchema,
    NotificationSchema,
    SingleUserNotificationReadSchema,
    TotalNotificationSchema,
)

notification_router_prefix = version_prefix + "notification"

notification_router = APIRouter(prefix=notification_router_prefix)


@notification_router.post(
    "/", response_model=GenericSingleResponse[NotificationReadSchema], status_code=201
)
@rbac_access_checker(
    resource=RBACResource.notification, rbac_access_type=RBACAccessType.create
)
async def send_notification(
    *,
    notification_in: NotificationCreateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    send a new notification
    """
    db = get_db_session()
    notification_repo = NotificationRepository(entity=NotificationModel)
    new_notification = notification_repo.send(db, obj_in=notification_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": new_notification,
    }


@notification_router.get(
    "/", response_model=GenericSingleResponse[TotalNotificationSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.notification, rbac_access_type=RBACAccessType.read_multiple
)
async def read_user_notifications(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    read all user's notifications
    """
    db = get_db_session()
    notification_repo = NotificationRepository(entity=NotificationModel)
    notifications_read = notification_repo.get_user_notifications(db)
    res_data = context_set_response_code_message.get()
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": notifications_read,
        "count": res_data.count
    }


@notification_router.patch(
    "/{notification_id}/read", response_model=Any, status_code=200
)
async def mark_as_read(
    *,
    notification_id: int,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    mark a notification as read
    """
    db = get_db_session()
    notification_repo = NotificationRepository(entity=NotificationModel)
    notification_repo.mark_notification_as_read(db, notification_id=notification_id)
    res_data = context_set_response_code_message.get()
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
    }


@notification_router.patch(
    "/read/all", response_model=Any, status_code=200
)
async def mark_all_as_read(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    mark all notifications as read
    """
    db = get_db_session()
    notification_repo = NotificationRepository(entity=NotificationModel)
    notification_repo.mark_all_notifications_as_read(db)
    res_data = context_set_response_code_message.get()
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
    }


# @notification_router.get(
#     "/single",
#     response_model=GenericSingleResponse[NotificationReadSchema],
#     status_code=200
# )
# async def read_single_notification (
#         *,
#         filters: Optional[NotificationsFilterSchema] = None,
#         notification_in: NotificationCreateSchema,
#         _=Depends(build_request_context),
#         request: Request,
#         response: Response
# ) -> Any:
#     """
#     read single notification
#     """
#     db = get_db_session()
#     notification_repo = NotificationRepository(entity=NotificationModel)
#     notification_read = notification_repo.get(db, filters)
#     res_data = context_set_response_code_message.get()
#     return {
#         'status_code': res_data.status_code,
#         'message': res_data.message,
#         'error': res_data.error,
#         'data': notification_read
#     }


@notification_router.get("s", response_model=list[NotificationSchema], status_code=200)
async def get_notification(
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    notifications = db.query(Notifications).filter(Notifications.user_id == user.id).all()

    return notifications

@notification_router.patch("s/{notification_id}/read")
async def mark_as_read(
    notification_id: uuid.UUID,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    notification = db.query(Notifications).filter(Notifications.id == notification_id, Notifications.user_id == user.id).first()

    if notification:
        notification.unread = False
        try:
            db.commit()
        except Exception as e:
            db.rollback()
            return Response(status_code=400, content=json.dumps({"message": "Failed to mark as read"}), media_type="application/json")

    return {"message": "Notification marked as read"}