from typing import Any, Optional
from fastapi import APIRouter, Depends, File, Form, Query, Response, UploadFile
from fastapi.responses import StreamingResponse
from fastapi.security import HTTPBearer
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db_session
from models.servicemodel import ServiceModel
from repositories.service import ServiceRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.serviceschema import (
    ServiceCreateSchema,
    ServiceFilterSchema,
    ServicePriceReadSchema,
    ServiceReadSchema,
    ServiceUpdateSchema,
)

service_router_prefix = version_prefix + "service"

service_router = APIRouter(prefix=service_router_prefix)


@service_router.post(
    "/", response_model=GenericSingleResponse[ServicePriceReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.service, rbac_access_type=RBACAccessType.create
)
async def create_service(
    *,
    service_in: ServiceCreateSchema,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    create a new service
    """
    db = get_db_session()
    service_repo = ServiceRepository(entity=ServiceModel)
    new_service = service_repo.create(db, obj_in=service_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": new_service,
    }


@service_router.post(
    "/paginated",
    response_model=GenericMultipleResponse[ServicePriceReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.service, rbac_access_type=RBACAccessType.read_multiple
)
async def read_services(
    *,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10,
    filters: Optional[ServiceFilterSchema] = None,
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve paginated services.
    """
    db = get_db_session()
    service_repo = ServiceRepository(entity=ServiceModel)
    services_read = service_repo.get_some(db, skip=skip, limit=limit, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": services_read,
        "count": res_data.count
    }


@service_router.post(
    "/single", response_model=GenericSingleResponse[ServicePriceReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.service, rbac_access_type=RBACAccessType.read
)
async def read_service(
    *,
    filters: ServiceFilterSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    fetch service detail
    """
    db = get_db_session()
    service_repo = ServiceRepository(entity=ServiceModel)
    service = service_repo.get(db, filter=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": service,
    }

@service_router.put(
    "/",
    response_model=GenericSingleResponse[ServiceReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.service, rbac_access_type=RBACAccessType.read
)
async def update_service(
    *,
    service_update: ServiceUpdateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    update service
    """
    db = get_db_session()
    service_repo = ServiceRepository(entity=ServiceModel)
    updated_service = service_repo.update(db, obj_in=service_update)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": updated_service
    }


@service_router.put(
    "/service/price",
    response_model=GenericSingleResponse[ServicePriceReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.service, rbac_access_type=RBACAccessType.read
)
async def update_service_price(
    *,
    price_update: ServiceUpdateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    update service price
    """
    db = get_db_session()
    service_repo = ServiceRepository(entity=ServiceModel)
    updated_service_price = service_repo.update_price(db, obj_in=price_update)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": updated_service_price,
    }
