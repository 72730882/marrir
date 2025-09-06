from typing import Any, Optional
from fastapi import APIRouter, Depends, File, Form, Response, UploadFile
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db_session
from models.invoicemodel import InvoiceModel
from repositories.invoice import InvoiceRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message, context_actor_user_data
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.invoiceschema import (
    InvoiceReadSchema,
)

invoice_router_prefix = version_prefix + "invoice"

invoice_router = APIRouter(prefix=invoice_router_prefix)


@invoice_router.post(
    "/",
    response_model=GenericSingleResponse[InvoiceReadSchema],
    status_code=201,
)
@rbac_access_checker(
    resource=RBACResource.payment, rbac_access_type=RBACAccessType.create
)
async def create_invoice(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    amount: float,
    transaction_id: str = Form(...),
    transaction_date=Form(...),
    user_profile_id: int = Form(...),
    transaction_screenshot: UploadFile = File(...),
    request: Request,
    response: Response
):
    """
    Make a invoice
    """
    db = get_db_session()
    invoice_repo = InvoiceRepository(entity=InvoiceModel)
    invoice_created = await invoice_repo.make_invoice(
        db=db,
        file=transaction_screenshot,
        amount=amount,
        type=type,
        transaction_date=transaction_date,
        transaction_id=transaction_id,
        user_profile_id=user_profile_id,
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": invoice_created,
    }


@invoice_router.post(
    "/paginated",
    response_model=GenericMultipleResponse[InvoiceReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.invoice, rbac_access_type=RBACAccessType.read_multiple
)
async def read_invoices(
    *,
    filters: Optional[InvoiceFilterSchema] = None,
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
    Retrieve paginated invoices.
    """
    db = get_db_session()
    invoice_repo = InvoiceRepository(entity=InvoiceModel)
    invoices_read = invoice_repo.get_some(
        db,
        skip=skip,
        limit=limit,
        search=search,
        search_schema=InvoiceSearchSchema,
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
        "data": invoices_read,
    }


@invoice_router.post(
    "/single", response_model=GenericSingleResponse[InvoiceReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.invoice, rbac_access_type=RBACAccessType.read
)
async def read_invoice(
    *,
    filters: Optional[InvoiceFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve single invoice.
    """
    db = get_db_session()
    invoice_repo = InvoiceRepository(entity=InvoiceModel)
    invoice_read = invoice_repo.get(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": invoice_read,
    }


@invoice_router.post(
    "/checkout/success", response_model=dict[str, str], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.invoice, rbac_access_type=RBACAccessType.read
)

async def invoice_successful(
    session_id: Optional[str] = None, 
    current_user = context_actor_user_data.get()
):
    invoice = await Invoice.get(transaction_id=session_id)
    invoice.status = PaidStatus.paid
    await invoice.save()
    return {"message": "Invoice Successful"}


@checkout_router.get("/cancelled", response_model=dict[str, str])
async def invoice_cancelled(current_user: Customer = Depends(get_current_active_user)):
    return {"message": "Invoice Cancelled"}