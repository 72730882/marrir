from typing import Any, Optional
from fastapi import APIRouter, Depends, Response
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db_session
from models.refundmodel import RefundModel
from repositories.refund import RefundRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.refundschema import (
    RefundCreateSchema,
    RefundFilterSchema,
    RefundReadSchema,
    RefundReviewSchema,
)

refund_router_prefix = version_prefix + "refund"

refund_router = APIRouter(prefix=refund_router_prefix)

@refund_router.post(
    "/",
    response_model=GenericSingleResponse[RefundReadSchema],
    status_code=201,
)
@rbac_access_checker(resource=RBACResource.refund, rbac_access_type=RBACAccessType.create)
async def request_refund(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    refund_in: RefundCreateSchema,
    request: Request,
    response: Response
):
    """
    Request a refund
    """
    db = get_db_session()
    refund_repo = RefundRepository(entity=RefundModel)
    refund_requested = refund_repo.request_refund(db=db, obj_in=refund_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": refund_requested,
    }


@refund_router.patch(
    "/", response_model=GenericSingleResponse[RefundReadSchema], status_code=201
)
@rbac_access_checker(resource=RBACResource.refund, rbac_access_type=RBACAccessType.update)
@rbac_access_checker(resource=RBACResource.refund, rbac_access_type=RBACAccessType.soft_delete)
async def review_refund(
    *,
    refund_in: RefundReviewSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    review refund request
    """
    db = get_db_session()
    refund_repo = RefundRepository(entity=RefundModel)
    review_refund = refund_repo.review_refund(db, obj_in=refund_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": review_refund,
    }


@refund_router.post(
    "/paginated", response_model=GenericMultipleResponse[RefundReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.refund, rbac_access_type=RBACAccessType.read_multiple
)
async def read_refunds(
    *,
    filters: Optional[RefundFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10,
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve paginated refunds.
    """
    db = get_db_session()
    refund_repo = RefundRepository(entity=RefundModel)
    refunds_read = refund_repo.get_some(db, skip=skip, limit=limit, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": refunds_read,
    }

@refund_router.post(
    "/single",
    response_model=GenericSingleResponse[RefundReadSchema],
    status_code=200
)
@rbac_access_checker(resource=RBACResource.refund, rbac_access_type=RBACAccessType.read)
async def read_refund(
        *,
        filters: Optional[RefundFilterSchema] = None,
        _=Depends(authentication_context),
        __=Depends(build_request_context),
        request: Request,
        response: Response
) -> Any:
    """
    Retrieve single refund.
    """
    db = get_db_session()
    refund_repo = RefundRepository(entity=RefundModel)
    refund_read = refund_repo.get(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        'status_code': res_data.status_code,
        'message': res_data.message,
        'error': res_data.error,
        'data': refund_read
    }


@refund_router.post(
    "/user", response_model=GenericMultipleResponse[RefundReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.refund, rbac_access_type=RBACAccessType.read_multiple
)
async def read_user_refunds(
    *,
    filters: Optional[RefundFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10,
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve paginated user specific refunds.
    """
    db = get_db_session()
    refund_repo = RefundRepository(entity=RefundModel)
    refunds_read = refund_repo.get_user_some(db, skip=skip, limit=limit, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": refunds_read,
    }
