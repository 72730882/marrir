import json
from typing import Any, Optional
from typing import List, Optional
from models.employeemodel import EmployeeModel
from fastapi import APIRouter, Depends, File, Form, Response, UploadFile, HTTPException, BackgroundTasks
from fastapi.security import HTTPBearer
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db, get_db_session
from models.paymentmodel import PaymentModel
from models.promotionmodel import PromotionPackagesModel
from models.reservemodel import ReserveModel
from repositories.payment import PaymentRepository
from models.usermodel import UserModel
from models.invoicemodel import InvoiceModel
from core.context_vars import context_set_response_code_message, context_actor_user_data
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.paymentschema import (
    PaymentFilterSchema,
    PaymentReadSchema,
    PaymentSearchSchema,
    PaymentStatusSchema,
    StripePaymentFilterSchema,
    StripePaymentReadSchema,
)

from pydantic import BaseModel
import httpx
import uuid
from datetime import datetime
from telr_payment.api import Telr
import os
from dotenv import load_dotenv
from core.security import settings
from schemas.reserveschema import ReservePay
from schemas.transferschema import TransferRequestPaymentCallback
from schemas.userschema import UserTokenSchema
import logging
from models.notificationmodel import Notifications
from utils.send_email import send_email

logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

payment_router = APIRouter(prefix=f"/payment")

telr = Telr(auth_key=settings.TELR_AUTH_KEY, store_id=settings.TELR_STORE_ID, test=settings.TELR_TEST_MODE)

def send_notification(db, user_id, title, description, type):
    notification = Notifications(
        title=title,
        description=description,
        type=type,
        user_id=user_id,
    )
    db.add(notification)

    try:
        db.commit()
    except Exception as e:
        logger.error(f"Failed to send notification: {e}")
        db.rollback()

class TelrPaymentRequest(BaseModel):
    amount: float
    method: bool
    package: Optional[str] = None
    user_id: str
class TelrPaymentMultipleRequest(BaseModel):
    amount: float
    method: bool
    package: Optional[str] = None
    user_ids: List[str]
@payment_router.post(
    "/",
    response_model=GenericSingleResponse[PaymentReadSchema],
    status_code=201,
)
@rbac_access_checker(
    resource=RBACResource.payment, rbac_access_type=RBACAccessType.create
)
async def make_payment(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    amount: float = Form(...),
    bank: str = Form(...),
    transaction_id: str = Form(...),
    transaction_date=Form(...),
    user_profile_id: int = Form(...),
    transaction_screenshot: UploadFile = File(...),
    request: Request,
    response: Response
):
    """
    Make a payment
    """
    db = get_db_session()
    payment_repo = PaymentRepository(entity=PaymentModel)
    payment_created = await payment_repo.make_payment(
        db=db,
        file=transaction_screenshot,
        amount=amount,
        bank=bank,
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
        "data": payment_created,
    }


@payment_router.post(
    "/approve",
    response_model=GenericSingleResponse[PaymentReadSchema],
    status_code=201,
)
@rbac_access_checker(
    resource=RBACResource.payment, rbac_access_type=RBACAccessType.create
)
async def approve_reject_payment(
    *,
    payment_filter: Optional[PaymentFilterSchema] = None,
    status: PaymentStatusSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
):
    """
    Decide on payment
    """
    db = get_db_session()
    payment_repo = PaymentRepository(entity=PaymentModel)
    payment_decided = await payment_repo.approve_payment(
        db=db,
        filter=payment_filter,
        status=status
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": payment_decided,
    }


@payment_router.post(
    "/paginated",
    response_model=GenericMultipleResponse[PaymentReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.payment, rbac_access_type=RBACAccessType.read_multiple
)
async def read_payments(
    *,
    filters: Optional[PaymentFilterSchema] = None,
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
    Retrieve paginated payments.
    """
    db = get_db_session()
    payment_repo = PaymentRepository(entity=PaymentModel)
    payments_read = payment_repo.get_some(
        db,
        skip=skip,
        limit=limit,
        search=search,
        search_schema=PaymentSearchSchema,
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
        "data": payments_read,
        "count": res_data.count,
    }


@payment_router.post(
    "/stripe/paginated",
    response_model=GenericMultipleResponse[StripePaymentReadSchema],
    status_code=200,
)

async def read_stripe_payments(
    *,
    filters: Optional[StripePaymentFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve paginated stripe payments.
    """
    db = get_db_session()
    payment_repo = PaymentRepository(entity=PaymentModel)
    payments_read = await payment_repo.get_stripe_payments(
        db,
        filters=filters,
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": payments_read,
        "count": res_data.count,
    }


@payment_router.post(
    "/single", response_model=GenericSingleResponse[PaymentReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.payment, rbac_access_type=RBACAccessType.read
)
async def read_payment(
    *,
    filters: Optional[PaymentFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve single payment.
    """
    db = get_db_session()
    payment_repo = PaymentRepository(entity=PaymentModel)
    payment_read = payment_repo.get(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": payment_read,
    }


from sqlalchemy.orm import Session

@payment_router.post("/telr/createx", response_model=dict, status_code=200)
async def create_telr_payment(
    payment_request: TelrPaymentRequest,
    db: Session = Depends(get_db),  
):
    """
    Create a payment transaction through Telr payment gateway.
    """
    if not payment_request.amount or payment_request.amount <= 0:
        raise HTTPException(
            status_code=400,
            detail="Invalid amount specified"
        )

    amount = payment_request.amount
    order_id = f"ORDER{uuid.uuid4().hex[:8]}"
    auth_key = settings.TELR_AUTH_KEY
    store_id = settings.TELR_STORE_ID
    return_url = settings.TELR_RETURN_URL

    print("DEBUG: Creating Telr payment with the following details:")
    print(f"store_id: {store_id}")
    print(f"order_id: {order_id}")
    print(f"amount: {amount}")
    print(f"return_url: {return_url}")

    try:
        # Call the payment processing function
        order_response = process_telr_payment(
            auth_key=auth_key,
            store_id=store_id,
            order_id=order_id,
            amount=amount,
            return_url=return_url,
            description=f"Profile Promotion - {payment_request.package or 'Standard'}",
            test_mode=True,  # Set to False for production
        )

        print("Telr Response:", order_response)

        if not order_response:
            raise HTTPException(status_code=400, detail="No response received from Telr.")

        if "error" in order_response:
            error_details = order_response.get("error", {})
            print("Telr Error Details:", error_details)
            raise HTTPException(
                status_code=400,
                detail=error_details
            )

        order_data = order_response.get("order", {})
        if not order_data or not order_data.get("ref"):
            raise HTTPException(
                status_code=400, 
                detail="Invalid response format from Telr - missing order reference"
            )

        try:
            custm_id = payment_request.user_id
            try:
                custm_id = uuid.UUID(custm_id)  # Ensure user_id is a valid UUID
            except ValueError:
                raise HTTPException(status_code=400, detail="Invalid user ID format.")

            user = db.query(UserModel).filter(UserModel.id == custm_id).first()
            if not user:
                raise HTTPException(status_code=400, detail="User not found")

            print("Debugging Invoice Data:")
            print(f"customer_id: {custm_id}")
            print(f"stripe_session_id: {order_data['ref']}")
            print(f"amount: {float(payment_request.amount)}")

            invoice_model = InvoiceModel(
                customer_id=custm_id,
                stripe_session_id=order_data["ref"],
                status="pending",
                amount=float(payment_request.amount),
                created_at=datetime.now(),
            )
            db.add(invoice_model)
            db.commit()
            db.refresh(invoice_model)

            print("Invoice saved successfully:", invoice_model)

        except HTTPException as he:
            raise he
        except Exception as db_error:
            if db:
                db.rollback()
            print(f"Database Error: {repr(db_error)}")
            raise HTTPException(
                status_code=500,
                detail={"message": "Failed to save invoice.", "error": repr(db_error)}
            )

        return {
            "method": order_response.get("method"),
            "trace": order_response.get("trace"),
            "order": {
                "ref": order_response.get("order", {}).get("ref"),
                "url": order_response.get("order", {}).get("url"),
            },
        }

    except HTTPException as he:
        print(f"HTTPException: {repr(he)}")
        raise he
    except Exception as e:
        print(f"Unexpected Error: {repr(e)}")
        raise HTTPException(
            status_code=500,
            detail={"message": "Failed to create payment with Telr.", "error": repr(e)},
        )


@payment_router.post("/telr/callback", status_code=200)
async def telr_payment_callback(
    request: Request,
    db: Session = Depends(get_db),
):
 
    try:
        callback_data = await request.json()  
        print("Raw Callback Data:", callback_data)
        cart_id = callback_data.get("cart_id")
        transaction_ref = callback_data.get("tran_ref")
        status = callback_data.get("status")
        print(f"Telr Callback Data - Cart ID: {cart_id}, Ref: {transaction_ref}, Status: {status}")
        if not transaction_ref:
            raise HTTPException(status_code=400, detail="Missing transaction reference")
        invoice = db.query(InvoiceModel).filter(
            InvoiceModel.stripe_session_id == transaction_ref
        ).first()
        if not invoice:
            raise HTTPException(status_code=404, detail="Invoice not found")
        if status.lower() in ["paid", "success", "a"]:  # Add other status codes if needed
            invoice.status = "paid"
            invoice.updated_at = datetime.now()
            try:
                db.commit()
                print(f"Invoice {invoice.id} status updated to paid")
            except Exception as e:
                db.rollback()
                print(f"Database commit failed: {repr(e)}")
                raise HTTPException(status_code=500, detail="Database commit failed")
        return {"status": "success", "message": "Callback processed successfully"}
    except Exception as e:
        print(f"Error processing Telr callback: {repr(e)}")
        raise HTTPException(
            status_code=500,
            detail={"message": "Failed to process payment callback", "error": repr(e)}
        )

def process_telr_payment(auth_key, store_id, order_id, amount, return_url, description, test_mode=True):
    """
    Process a payment using the Telr SDK.
    """
    try:
        telr = Telr(auth_key=auth_key, store_id=store_id, test=int(test_mode))
        formatted_amount = "{:.2f}".format(float(amount))
        response = telr.order(
            order_id=order_id,
            amount=formatted_amount,
            description=description,
            return_url=return_url,
            return_decl=return_url,
            return_can=return_url,
            currency="AED"
        )
        print("Debug - Raw Telr response:", response)
        return response
    except Exception as e:
        print(f"Error in Telr SDK: {repr(e)}")
        raise


@payment_router.post("/telr/multiple/create", response_model=dict, status_code=200)
async def create_telr_payment(
    payment_request: TelrPaymentMultipleRequest,
    db: Session = Depends(get_db),
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    """
    Create a payment transaction through Telr payment gateway for multiple users.
    """
    buyer = context_actor_user_data.get()
    if not payment_request.amount or payment_request.amount <= 0:
        raise HTTPException(
            status_code=400, detail="Invalid amount specified"
        )

    amount = payment_request.amount
    order_id = f"ORDER{uuid.uuid4().hex[:8]}"

    auth_key = settings.TELR_AUTH_KEY
    store_id = settings.TELR_STORE_ID
    return_url = settings.TELR_RETURN_URL.replace("replace", buyer.role)

    try:
        # Call the payment processing function
        order_response = multiple_process_telr_payment(
            auth_key=auth_key,
            store_id=store_id,
            order_id=order_id,
            amount=amount,
            return_url=return_url,
            description=f"Profile Promotion - {payment_request.package or 'Standard'}",
            test_mode=True,  # Set to False for production
        )

        if not order_response:
            raise HTTPException(
                status_code=400, detail="No response received from Telr."
            )

        if "error" in order_response:
            error_details = order_response.get("error", {})
            print("Telr Error Details:", error_details)
            raise HTTPException(status_code=400, detail=error_details)

        order_data = order_response.get("order", {})
        if not order_data or not order_data.get("ref"):
            raise HTTPException(
                status_code=400,
                detail="Invalid response format from Telr - missing order reference",
            )

        # Iterate through the user IDs and create invoices for each
        for user_id_str in payment_request.user_ids:
            try:
                custm_id = uuid.UUID(user_id_str)  # Ensure user_id is a valid UUID
            except ValueError:
                raise HTTPException(
                    status_code=400, detail=f"Invalid user ID format: {user_id_str}"
                )

            user = db.query(UserModel).filter(UserModel.id == custm_id).first()
            if not user:
                raise HTTPException(
                    status_code=400, detail=f"User not found with ID: {user_id_str}"
                )

            invoice_model = InvoiceModel(
                customer_id=custm_id,
                stripe_session_id=order_data["ref"],
                status="pending",
                amount=float(payment_request.amount),
                created_at=datetime.now(),
                type="profile_promotion",
                buyer_id=buyer.id,
            )
            db.add(invoice_model)
            db.commit()
            db.refresh(invoice_model)

            print("Invoice saved successfully:", invoice_model)

        return {
            "method": order_response.get("method"),
            "trace": order_response.get("trace"),
            "order": {
                "ref": order_response.get("order", {}).get("ref"),
                "url": order_response.get("order", {}).get("url"),
            },
        }

    except HTTPException as he:
        print(f"HTTPException: {repr(he)}")
        raise he
    except Exception as e:
        if db:
            db.rollback() # Rollback in case of any exception during the invoice saving loop.
        print(f"Unexpected Error: {repr(e)}")
        raise HTTPException(
            status_code=500,
            detail={
                "message": "Failed to create payment with Telr.",
                "error": repr(e),
            },
        )


@payment_router.post("/telr/multiple/callback", status_code=200)
async def telr_payment_callback(
    request: Request,
    db: Session = Depends(get_db),
):
    """
    Handle Telr payment callback and update invoice status.
    """
    try:
        # Get the callback data from Telr
        callback_data = await request.json()  # Use request.form() if Telr sends form data

        # Extract the transaction reference and status
        ref = callback_data.get("ref")

        # Validate the transaction reference
        if not ref:
            raise HTTPException(status_code=400, detail="Missing transaction reference")
        
        status_response = telr.status(
            order_reference = ref
        )
        state = status_response.get("order").get("status").get("text")

        card_type = status_response.get("order", {}).get("card", {}).get("type")

        description = status_response.get("order", {}).get("description")

        if state.lower()  == "pending":
            return {"status": "failed", "message": "Payment is pending"}

        # Find all invoices with the Telr reference (stripe_session_id)
        invoice = db.query(InvoiceModel).filter(
            InvoiceModel.stripe_session_id == ref
        ).first()

        # Check if any  were found
        if not invoice:
            raise HTTPException(status_code=404, detail="No invoices found for this transaction reference")

        invoice.status = state.lower()
        invoice.card = card_type
        invoice.description = description


        try:
            db.commit()
        except Exception as e:
            db.rollback()
            print(f"Database commit failed: {repr(e)}")
            raise HTTPException(status_code=500, detail="Database commit failed")            

        # Return success response
        return {"status": "success", "message": "Callback processed successfully"}

    except HTTPException as he:
        print(f"HTTPException: {repr(he)}")
        raise he
    except Exception as e:
        # Log the error and return a 500 response
        print(f"Error processing Telr callback: {repr(e)}")
        raise HTTPException(
            status_code=500,
            detail={"message": "Failed to process payment callback", "error": repr(e)},
        )


def multiple_process_telr_payment(
    auth_key, store_id, order_id, amount, return_url, description, test_mode=True
):
    """
    Process a payment using the Telr SDK.
    """
    try:
        # Initialize Telr SDK
        telr = Telr(auth_key=auth_key, store_id=store_id, test=settings.TELR_TEST_MODE)

        # Format the amount to 2 decimal places
        formatted_amount = "{:.2f}".format(float(amount))

        # Create a payment order using Telr SDK
        response = telr.order(
            order_id=order_id,
            amount=formatted_amount,
            description=description,
            return_url=return_url,
            return_decl=return_url,
            return_can=return_url,
            currency="AED",
        )

        # Log the raw Telr response for debugging
        print("Debug - Raw Telr response:", response)

        # Return the response
        return response
    except Exception as e:
        # Log the error and re-raise the exception
        print(f"Error in Telr SDK: {repr(e)}")
        raise


@payment_router.get("/")
async def get_payments(_=Depends(HTTPBearer(scheme_name="bearer")), __=Depends(build_request_context)):
    db = get_db_session()

    user = context_actor_user_data.get()

    payments = db.query(InvoiceModel).filter(
        (InvoiceModel.buyer_id == user.id) | (InvoiceModel.customer_id == user.id)
    ).all()

    data = []

    for payment in payments:
        data.append({
            "id": payment.id,
            "customer_id": payment.customer_id,
            "ref": payment.stripe_session_id,
            "status": payment.status,
            "amount": payment.amount,
            "currency": payment.currency,
            "type": payment.type,
            "card": payment.card,
            "description": payment.description,
            "buyer_id": payment.buyer_id,
            "created_at": payment.created_at,
            "updated_at": payment.updated_at
        })

    return data


def create_invoice(db, ref: str, amount: float, user_id: int, reserve_id: int) -> InvoiceModel:
    invoice = InvoiceModel(
        stripe_session_id=ref,
        status="pending",
        amount=amount,
        created_at=datetime.now(),
        type="reservation",
        buyer_id=user_id,
        object_id=reserve_id,
    )
    db.add(invoice)
    return invoice

def update_invoice(invoice: InvoiceModel, ref: str) -> None:
    invoice.stripe_session_id = ref

@payment_router.post("/telr/create")
async def pay_reserve(
    data: ReservePay,
    db: Session = Depends(get_db),  
):
    user = db.query(UserModel).filter(UserModel.id == data.user_id).first()
    if not user:
        return Response(status_code=404, content=json.dumps({"message": "User not found"}), media_type="application/json")

    package = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.role == user.role, PromotionPackagesModel.category == "reservation").first()

    reservations = db.query(ReserveModel).filter(
            ReserveModel.id.in_(data.metadata.reserve_ids),
            ReserveModel.reserver_id == user.id,
            ReserveModel.status == "accepted"
    ).all()
    
    if not reservations:
        return Response(status_code=404, content=json.dumps({"message": "Reservations not found"}), media_type="application/json")

    return_url = settings.TELR_RESERVE_RETURN_URL.replace("replace", user.role)
    amount = package.price * len(reservations)

    order_response = telr.order(
        order_id=f"ORDER{uuid.uuid4().hex[:8]}",
        amount=amount,
        return_url=return_url,
        return_decl=return_url,
        return_can=return_url,
        description="Reservation Payment",
    )

    ref = order_response.get("order", {}).get("ref")

    if not ref:
        return Response(status_code=400, content=json.dumps({"message": "Failed to create order"}), media_type="application/json")

    ids = ",".join([str(tr.id) for tr in reservations])

    invoice = db.query(InvoiceModel).filter(
        InvoiceModel.object_id == ids,
        InvoiceModel.buyer_id == user.id,
        InvoiceModel.status == "pending",
        InvoiceModel.type == "reservation"
    ).first()

    try:
        if invoice:
            update_invoice(invoice, ref)
        else:
            invoice = create_invoice(db, ref, amount, user.id, ids)
            db.add(invoice)
        db.commit()
    except Exception as e:
        logger.error(f"Failed to process invoice: {e}")
        db.rollback()
        return Response(status_code=400, content=json.dumps({"message": "Failed to process invoice"}), media_type="application/json")

    return {
        "price": package.price,
        "total_price": amount,
        "total_reserves": len(reservations),
        "method": order_response.get("method"),
        "trace": order_response.get("trace"),
        "order": {
            "ref": order_response.get("order", {}).get("ref"),
            "url": order_response.get("order", {}).get("url"),
        },
    }

'''
@payment_router.post("/reserve/callback")
async def telr_reserve_callback(data: TransferRequestPaymentCallback, background_tasks: BackgroundTasks, _=Depends(HTTPBearer (scheme_name="bearer")),__=Depends(build_request_context)):
    db = get_db_session()

    user = context_actor_user_data.get()
    status_response = telr.status(
            order_reference = data.ref
    )
    state = status_response.get("order", {}).get("status", {}).get("text", "")
    
    error = status_response.get("error", {})

    card_type = status_response.get("order", {}).get("card", {}).get("type")

    description = status_response.get("order", {}).get("description")

    if error:
        return Response(status_code=400, content=json.dumps({"message": error.get("note", "Failed to process payment")}), media_type="application/json")

    if state.lower()  == "pending":
        return Response(status_code=400, content=json.dumps({"message": "Payment is pending"}), media_type="application/json")

    invoice = db.query(InvoiceModel).filter(
        InvoiceModel.stripe_session_id == data.ref,
        InvoiceModel.buyer_id == user.id,
        InvoiceModel.status == "pending",
        InvoiceModel.type == "reservation"
    ).first()

    reservations = db.query(ReserveModel).filter(
            ReserveModel.id.in_(map(int, invoice.object_id.split(','))),
            ReserveModel.reserver_id == user.id,
            ReserveModel.status == "accepted"
    ).all()

    try:
        for reservation in reservations:
            reservation.status = "paid"
            db.add(reservation)

        invoice.status = "paid"
        invoice.card = card_type
        invoice.description = description
        db.add(invoice)

        _user = db.query(UserModel).filter(UserModel.id == user.id).first()

        email = _user.email or _user.company.alternative_email
        title = "Reservation paid"
        description = f"Your reservation has been successfully paid for {invoice.amount} AED. You have reserved {len(reservations)} profiles."

        background_tasks.add_task(send_notification, db, user.id, title, description, "reservation")
        background_tasks.add_task(func=send_email, email=email, title=title, description=description)

        title = "Reservation Finished"
        description = (
            f"{_user.company.company_name} has successfully paid for {len(reservations)} reservations. "
            f"The contact information for {_user.company.company_name} are: {email}, {_user.phone_number}, {_user.company.location}."
        )
        
        owner_email = reservations[0].owner.email or reservations[0].owner.company.alternative_email

        background_tasks.add_task(send_notification, db, reservations[0].owner_id, title, description, "reservation")

        background_tasks.add_task(func=send_email, email=owner_email, title=title, description=description)

        db.commit()
        return {"status": "success", "message": "Payment successful"}
 
    except Exception as e:
        db.rollback()
        logger.error(f"Failed to process payment: {e}")
        return Response(status_code=400, content=json.dumps({"message": "Failed to process payment"}), media_type="application/json")
'''

@payment_router.post("/reserve/callback")
async def telr_reserve_callback(data: TransferRequestPaymentCallback, background_tasks: BackgroundTasks, _=Depends(HTTPBearer (scheme_name="bearer")),__=Depends(build_request_context)):
    db = get_db_session()
    user = context_actor_user_data.get()
    
    try:
        status_response = telr.status(
            order_reference = data.ref
        )
        state = status_response.get("order", {}).get("status", {}).get("text", "")
        
        error = status_response.get("error", {})
        card_type = status_response.get("order", {}).get("card", {}).get("type")
        description = status_response.get("order", {}).get("description")

        if error:
            return Response(status_code=400, content=json.dumps({"message": error.get("note", "Failed to process payment")}), media_type="application/json")

        if state.lower() == "pending":
            return Response(status_code=400, content=json.dumps({"message": "Payment is pending"}), media_type="application/json")

        invoice = db.query(InvoiceModel).filter(
            InvoiceModel.stripe_session_id == data.ref,
            InvoiceModel.buyer_id == user.id,
            InvoiceModel.status == "pending",
            InvoiceModel.type == "reservation"
        ).first()

        if not invoice:
            return Response(status_code=404, content=json.dumps({"message": "Invoice not found"}), media_type="application/json")

        reservations = db.query(ReserveModel).filter(
            ReserveModel.id.in_(map(int, invoice.object_id.split(','))),
            ReserveModel.reserver_id == user.id,
            ReserveModel.status == "accepted"
        ).all()

        if not reservations:
            return Response(status_code=404, content=json.dumps({"message": "Reservations not found"}), media_type="application/json")
        '''
        for reservation in reservations:
            reservation.owner_id = reservation.reserver_id
           
            db.add(reservation)
        '''
        for reservation in reservations:
            reservation.status = "paid"
            reservation.owner_id = reservation.reserver_id  # Transfer ownership

            # Try to update the EmployeeModel
            cv_user_id = reservation.cv.user_id  # Assuming CVModel has user_id field
            employee = db.query(EmployeeModel).filter_by(user_id=cv_user_id).first()
            if employee:
                employee.manager_id = reservation.reserver_id
                db.add(employee)

            db.add(reservation)

        invoice.status = "paid"
        invoice.card = card_type
        invoice.description = description
        db.add(invoice)

        _user = db.query(UserModel).filter(UserModel.id == user.id).first()
        if not _user:
            return Response(status_code=404, content=json.dumps({"message": "User not found"}), media_type="application/json")

        # Get email from user or company alternative email
        email = _user.email
        if not email and _user.company:
            email = _user.company.alternative_email

        title = "Reservation paid"
        description = f"Your reservation has been successfully paid for {invoice.amount} AED. You have reserved {len(reservations)} profiles."

        background_tasks.add_task(send_notification, db, user.id, title, description, "reservation")
        if email:
            background_tasks.add_task(func=send_email, email=email, title=title, description=description)

        # Get owner information
        owner = reservations[0].owner
        if owner:
            title = "Reservation Finished"
            company_name = _user.company.company_name if _user.company else "Unknown Company"
            location = _user.company.location if _user.company else "Unknown Location"
            
            description = (
                f"{company_name} has successfully paid for {len(reservations)} reservations. "
                f"The contact information for {company_name} are: {email or 'No email'}, {_user.phone_number or 'No phone'}, {location}."
            )
            
            owner_email = owner.email
            if not owner_email and owner.company:
                owner_email = owner.company.alternative_email

            background_tasks.add_task(send_notification, db, owner.id, title, description, "reservation")
            if owner_email:
                background_tasks.add_task(func=send_email, email=owner_email, title=title, description=description)

        db.commit()
        return {"status": "success", "message": "Payment successful"}
 
    except Exception as e:
        db.rollback()
        logger.error(f"Failed to process payment: {str(e)}", exc_info=True)
        return Response(status_code=400, content=json.dumps({"message": "Failed to process payment"}), media_type="application/json")