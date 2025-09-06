from typing import Any, Optional
from fastapi import APIRouter, Depends, Response
from fastapi.security import HTTPBearer
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db_session
from models.employeestatusmodel import EmployeeStatusModel
from repositories.employeestatus import EmployeeStatusRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.employeestatusschema import (
    EmployeeStatusCreateSchema,
    EmployeeStatusFilterSchema,
    EmployeeStatusReadSchema,
    EmployeeStatusUpdateSchema,
)

employee_status_router_prefix = version_prefix + "employee_status"

employee_status_router = APIRouter(prefix=employee_status_router_prefix)


@employee_status_router.post(
    "/",
    response_model=GenericSingleResponse[EmployeeStatusReadSchema],
    status_code=201,
)
@rbac_access_checker(
    resource=RBACResource.employee_status, rbac_access_type=RBACAccessType.create
)
async def add_employee_status(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    employee_status_in: EmployeeStatusCreateSchema,
    request: Request,
    response: Response,
):
    """
    add employee status update
    """
    db = get_db_session()
    employee_status_repo = EmployeeStatusRepository(entity=EmployeeStatusModel)
    employee_status_requested = employee_status_repo.add_employee_status(
        db=db, obj_in=employee_status_in
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": employee_status_requested,
    }


@employee_status_router.post(
    "/updates",
    response_model=GenericMultipleResponse[EmployeeStatusReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.employee_status, rbac_access_type=RBACAccessType.read_multiple
)
async def read_employee_statuses(
    *,
    filters: Optional[EmployeeStatusFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve paginated employee status updates.
    """
    db = get_db_session()
    employee_status_repo = EmployeeStatusRepository(entity=EmployeeStatusModel)
    employee_status_read = employee_status_repo.get_employee_status(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": employee_status_read,
        "count": res_data.count,
    }


@employee_status_router.put(
    "/", response_model=GenericSingleResponse[EmployeeStatusReadSchema], status_code=200
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.update)
async def update_employee_status(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    status_update: EmployeeStatusUpdateSchema,
    request: Request,
    response: Response,
) -> Any:
    """
    Update employee status.

    """
    db = get_db_session()
    employee_status_repo = EmployeeStatusRepository(entity=EmployeeStatusModel)
    employee_status_updated = employee_status_repo.update(
        db, filter_obj_in=status_update.filter, obj_in=status_update.update
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": employee_status_updated,
    }


@employee_status_router.delete(
    "/", response_model=GenericSingleResponse[EmployeeStatusReadSchema], status_code=200
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.delete)
async def delete_employee_status(
    *,
    filters: Optional[EmployeeStatusFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Delete employee status update.
    """
    db = get_db_session()
    employee_status_repo = EmployeeStatusRepository(entity=EmployeeStatusModel)
    employee_status_deleted = employee_status_repo.delete(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": employee_status_deleted,
    }

@employee_status_router.post(
    "/generate-pdf",
    response_model=None,
    status_code=200,
)
async def generate_status_report(
    *,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    filters: Optional[EmployeeStatusFilterSchema] = None,
    request: Request,
    response: Response,
) -> Any:
    """
    generate status report.
    """
    db = get_db_session()
    status_repo = EmployeeStatusRepository(entity=EmployeeStatusModel)
    status_created = status_repo.export_to_pdf_status(
        db, request=request, title="Employee Status Report", filters=filters
    )

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": status_created,
    }
