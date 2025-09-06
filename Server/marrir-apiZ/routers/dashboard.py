from typing import Any, Optional
from fastapi import APIRouter, Depends, Response
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db_session
from repositories.dashboard import DashboardRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.dashboardstatschema import (
    DashboardAdminStatSchema,
    DashboardFilterSchema,
    DashboardStatSchema,
    NonEmployeeDashboardStatSchema,
)

dashboard_router_prefix = version_prefix + "dashboard"

dashboard_router = APIRouter(prefix=dashboard_router_prefix)


@dashboard_router.post(
    "/",
    response_model=GenericSingleResponse[NonEmployeeDashboardStatSchema],
    status_code=200,
)
async def get_non_employee_dashboard_data(
    *,
    period: Optional[str] = "monthly",
    filters: DashboardFilterSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    get non-employee dashboard stat
    """
    db = get_db_session()
    dashboard_repo = DashboardRepository()
    dashboard_stat = dashboard_repo.get_non_employee_dashboard_data(
        db, period=period, filters=filters
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": dashboard_stat,
    }


@dashboard_router.post(
    "/employee",
    response_model=GenericSingleResponse[DashboardStatSchema],
    status_code=200,
)
async def get_dashboard_data(
    *,
    period: Optional[str] = "monthly",
    filters: DashboardFilterSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    get dashboard stat
    """
    db = get_db_session()
    dashboard_repo = DashboardRepository()
    dashboard_stat = dashboard_repo.get_dashboard_data(
        db, period=period, filters=filters
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": dashboard_stat,
    }


@dashboard_router.post(
    "/admin",
    response_model=GenericSingleResponse[DashboardAdminStatSchema],
    status_code=200,
)
async def get_admin_dashboard_data(
    *,
    period: Optional[str] = "monthly",
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    get admin dashboard stat
    """
    db = get_db_session()
    dashboard_repo = DashboardRepository()
    dashboard_stat = dashboard_repo.get_admin_dashboard_data(db, period=period)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": dashboard_stat,
    }
