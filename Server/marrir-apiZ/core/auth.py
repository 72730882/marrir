from enum import Enum
from functools import wraps

from core.context_vars import context_actor_user_data
from core.security import decode_user_access_token, decode_user_refresh_token
from schemas.userschema import UserRoleSchema
from utils.exceptions import AppException


class RBACResource(str, Enum):
    # naming should be plural of resource
    # naming should omit table_ prefix from the resource table name on database
    user = "user"
    notification = "notification"
    job = "job"
    job_application = "jobapplication"
    cv = "cv"
    process = "process"
    payment = "payment"
    refund = "refund"
    offer = "offer"
    occupation = "occupation"
    transfer = "transfer"
    reserve = "reserve"
    promotion = "promotion"
    rating = "rating"
    company_info = "companyinfo"
    service = "service"
    employee_status = "employeestatus"
    assign_agent = "assignagent"


class RBACAccessType(str, Enum):
    create = "create"
    read = "read"
    read_multiple = "read_multiple"
    update = "update"
    delete = "delete"
    soft_delete = "soft_delete"


# resource to role mapping for RBAC
RBAC_MAPPER = {
    RBACResource.user: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.soft_delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
    },
    RBACResource.notification: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.soft_delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
    },
    RBACResource.job: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.soft_delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
    },
    RBACResource.job_application: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
        ],
    },
    RBACResource.cv: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
    },
    RBACResource.process: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
    },
    RBACResource.refund: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
        ],
        RBACAccessType.update: [UserRoleSchema.ADMIN],
        RBACAccessType.soft_delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
        ],
    },
    RBACResource.payment: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
        ],
        RBACAccessType.soft_delete: [UserRoleSchema.ADMIN],
    },
    RBACResource.occupation: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
        ],
        RBACAccessType.delete: [
            UserRoleSchema.ADMIN,
        ],
    },
    RBACResource.offer: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
        ],
        RBACAccessType.delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
    },
    RBACResource.transfer: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
    },
    RBACResource.reserve: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
    },
    RBACResource.promotion: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
    },
    RBACResource.rating: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.delete: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
    },
    RBACResource.company_info: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
             UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
    },
    RBACResource.employee_status: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SELFSPONSOR,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SELFSPONSOR,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SELFSPONSOR,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SELFSPONSOR,
        ],
    },
    RBACResource.assign_agent: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
        RBACAccessType.read: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.AGENT,
            UserRoleSchema.RECRUITMENT,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
        ],
        RBACAccessType.update: [
            UserRoleSchema.ADMIN,
            UserRoleSchema.AGENT,
            UserRoleSchema.EMPLOYEE,
            UserRoleSchema.SELFSPONSOR,
            UserRoleSchema.SPONSOR,
            UserRoleSchema.RECRUITMENT,
        ],
    },
    RBACResource.service: {
        RBACAccessType.create: [
            UserRoleSchema.ADMIN,
        ],
        RBACAccessType.read_multiple: [
            UserRoleSchema.ADMIN,
        ],
        RBACAccessType.read: [UserRoleSchema.ADMIN],
        # RBACAccessType.update: [
        #     UserRoleSchema.ADMIN,
        #     UserRoleSchema.AGENT,
        #     UserRoleSchema.RECRUITMENT,
        # ],
    },
}


def auth_checker(func):
    @wraps(func)
    def wrapper(request, *args, **kwargs):
        authorization = request.headers.get("Authorization")
        if authorization is None:
            raise AppException(
                status_code=401,
                message="no / incomplete / expired authentication credentials",
            )
        scheme, _, token = authorization.partition(" ")
        if not scheme or scheme.lower() != "bearer" or not token:
            raise AppException(
                status_code=401, message="Invalid authorization credentials format"
            )
        decoded_access_token = decode_user_access_token(token)
        if decoded_access_token is None:
            raise AppException(
                status_code=401, message="no / expired authentication credentials"
            )

        return func(*args, **kwargs)

    return wrapper


def rbac_access_checker(
    resource: RBACResource, rbac_access_type: RBACAccessType = RBACAccessType.read
):
    """
    RBAC access checker decorator for endpoints to check
    if the user has access to the resource or not based on the role
    and access_type provided
    :param rbac_access_type:  access type
    :param resource:  resource name
    :return:
    """

    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Check if the user has access to the resource or not based on the role
            # get user data from context
            actor = context_actor_user_data.get()

            if actor is None:
                raise AppException(
                    status_code=403,
                    message=f"you are not allowed to access resource {resource}"
                    f" with operation {rbac_access_type}",
                )
            if actor.role not in RBAC_MAPPER.get(resource).get(rbac_access_type, []):
                raise AppException(
                    status_code=403,
                    message=f"you are not allowed to access resource {resource}"
                    f" with operation {rbac_access_type}",
                )
            return await func(*args, **kwargs)

        return wrapper

    return decorator
