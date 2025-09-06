from typing import Any, Optional
from fastapi import APIRouter, Depends, Query, Response
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db_session
from models.offermodel import OfferModel
from repositories.offer import OfferRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.offerschema import (
    OfferBaseSchema,
    OfferCreateSchema,
    OfferReadSchema,
    OfferUpdateSchema,
    OfferFilterSchema,
)

offer_router_prefix = version_prefix + "offer"

offer_router = APIRouter(prefix=offer_router_prefix)


@offer_router.post(
    "/", response_model=GenericSingleResponse[OfferReadSchema], status_code=201
)
@rbac_access_checker(
    resource=RBACResource.offer, rbac_access_type=RBACAccessType.create
)
async def send_offer(
    *,
    offer_in: OfferCreateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    send a new offer
    """
    db = get_db_session()
    offer_repo = OfferRepository(entity=OfferModel)
    new_offer = offer_repo.send_offer(db, obj_in=offer_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": new_offer,
    }


@offer_router.post(
    "/paginated",
    response_model=GenericMultipleResponse[OfferReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.offer, rbac_access_type=RBACAccessType.read_multiple
)
async def view_offers(
    *,
    filters: Optional[OfferFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10,
    search: str = None,
    start_date: str = None,
    end_date: str = None,
    request: Request,
    response: Response
) -> Any:
    """
    View paginated offers
    """
    db = get_db_session()
    offer_repo = OfferRepository(entity=OfferModel)
    offers_read = offer_repo.view_offers(        
        db,
        skip=skip,
        limit=limit,
        search=search,
        search_schema=None,
        start_date=start_date,
        end_date=end_date,
        filters=filters,
)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": offers_read,
        "count": res_data.count
    }


@offer_router.post(
    "/single", response_model=GenericSingleResponse[OfferReadSchema], status_code=200
)
@rbac_access_checker(resource=RBACResource.offer, rbac_access_type=RBACAccessType.read)
async def view_single_offer(
    *,
    filters: Optional[OfferFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    View single offer
    """
    db = get_db_session()
    offer_repo = OfferRepository(entity=OfferModel)
    offer_read = offer_repo.get(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": offer_read,
    }


@offer_router.patch(
    "/", response_model=GenericSingleResponse[OfferReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.offer, rbac_access_type=RBACAccessType.update
)
async def accept_decline_offer(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    offer_update: OfferUpdateSchema,
    request: Request,
    response: Response
) -> Any:
    """
    Update offer status
    """
    db = get_db_session()
    offer_repo = OfferRepository(entity=OfferModel)
    offer_updated = offer_repo.accept_decline_offer(
        db, filter_obj_in=offer_update.filter, obj_in=offer_update.update
    )

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": offer_updated,
    }


@offer_router.delete(
    "/", response_model=GenericSingleResponse[OfferReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.offer, rbac_access_type=RBACAccessType.delete
)
async def rescind_offer(
    *,
    filters: Optional[OfferFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    rescind offer
    """
    db = get_db_session()
    offer_repo = OfferRepository(entity=OfferModel)
    offer_deleted = offer_repo.rescind_offer(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": offer_deleted,
    }
