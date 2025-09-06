from typing import Any, Dict, Optional
from fastapi import APIRouter, Depends, Response
from fastapi.security import HTTPBearer
from starlette.requests import Request
from models.db import authentication_context, build_request_context, get_db_session
from repositories.stat import StatRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message
from schemas.base import GenericSingleResponse
from schemas.dashboardstatschema import StatSchema

stat_router_prefix = version_prefix + "stat"

stat_router = APIRouter(prefix=stat_router_prefix)


@stat_router.post(
    "/", response_model=GenericSingleResponse[StatSchema], status_code=200
)
async def get_non_employee_dashboard_data(
    *,
    stat_type: str,
    period: Optional[str] = "monthly",
    filters: Optional[Dict[str, Any]] = None,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    # _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    get stats
    """
    db = get_db_session()
    stat_repo = StatRepository()
    stat = stat_repo.get_stats(db, stat_type=stat_type, period=period, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": stat,
    }
