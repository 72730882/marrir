from typing import Any, Optional
from fastapi import APIRouter, Depends, File, Form, HTTPException, Response, UploadFile
from starlette.requests import Request
import stripe
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db_session
from models.invoicemodel import InvoiceModel
from repositories.checkout import CheckoutRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message, context_actor_user_data
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.checkoutschema import CheckoutCreateSchema


checkout_router_prefix = version_prefix + "checkout"

checkout_router = APIRouter(prefix=checkout_router_prefix)

@checkout_router.post(
    "/create-checkout-session", response_model=dict[str, str], status_code=200
)
async def create_checkout_session(
    *,
    obj_in: CheckoutCreateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    db = get_db_session()
    checkout_repo = CheckoutRepository()
    checkout = checkout_repo.create_session(db, obj_in=obj_in)
    return checkout


@checkout_router.post(
    "/webhook", response_model=dict[str, str], status_code=200
)
async def stripe_webhook(
    *,
    _=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    db = get_db_session()
    checkout_repo = CheckoutRepository()
    checkout = await checkout_repo.webhook(db, request=request)
    return checkout
