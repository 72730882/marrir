from datetime import datetime, timedelta, timezone
import json
from typing import Any, List, Optional
import uuid
from repositories.promotion import PromotionRepository
from fastapi import APIRouter, Depends, Query, Response, UploadFile, BackgroundTasks
from fastapi.security import HTTPBearer
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.batchreservemodel import BatchReserveModel
from models.companyinfomodel import CompanyInfoModel
from models.db import authentication_context, build_request_context, get_db_raw, get_db_session, get_db_sessions
from models.invoicemodel import InvoiceModel
from models.notificationmodel import Notifications
from models.promotionmodel import DurationEnum, PromotionPackagesModel
from models.reservemodel import RecruitmentReserveModel, ReserveModel
from models.usermodel import UserModel
from repositories.reserve import ReserveRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message, context_actor_user_data
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.cvschema import CVSearchSchema
from schemas.enumschema import UserRoleSchema
from schemas.reserveschema import (
    BatchReserveReadSchema,
    GenericMultipleResponseEmployee,
    GenericMultipleResponseManager,
    RecruitmentReserveCreate,
    RecruitmentReserveReadSchema,
    RecruitmentReserveStatusUpdate,
    RecruitmentReserveSubscriptionBuy,
    ReserveBaseSchema,
    ReserveCVFilterSchema,
    ReserveCreateSchema,
    ReserveFilterSchema,
    ReservePay,
    ReserveReadSchema,
    ReserveUpdateSchema,
)
from schemas.transferschema import TransferRequestPaymentCallback
from schemas.userschema import UsersSearchSchema
from cron_jobs import pending_reserves_notification, scheduler, delete_old_pending_reserve  # Import the scheduler and function
from core.security import settings
from telr_payment.api import Telr
import logging

from utils.send_email import send_email
from sqlalchemy.orm import Session
from fastapi import Depends


logger = logging.getLogger(__name__)

reserve_router_prefix = version_prefix + "reserve"

reserve_router = APIRouter(prefix=reserve_router_prefix)

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
'''
@reserve_router.post(
    "/", status_code=201
)
@rbac_access_checker(
    resource=RBACResource.reserve, rbac_access_type=RBACAccessType.create
)
async def reserve_cv(
    *,
    reserve_in: ReserveCreateSchema,
    background_tasks: BackgroundTasks,
    
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    create a new reserve request
    """
    db = get_db_session()
    user = context_actor_user_data.get()
    reserve_in.reserver_id = user.id
    reserve_repo = ReserveRepository(entity=ReserveModel)
    new_reserve = reserve_repo.send_reserve_request(db, obj_in=reserve_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code

    for reserve in new_reserve:
        run_date = datetime.now(timezone.utc) + timedelta(hours=24)
        reminder_date = datetime.now(timezone.utc) + timedelta(hours=23)
        scheduler.add_job(delete_old_pending_reserve, 'date', run_date=run_date, args=[reserve.cv_id, db])
        scheduler.add_job(pending_reserves_notification, 'date', run_date=reminder_date, args=[reserve.cv_id, db])

    title = "Reserve Request"
    description = "Your promoted profile(s) has been reserved. Please accept the reservation within 24 hours, or it will become available for reservation again."

    background_tasks.add_task(send_notification, db, new_reserve[0].owner_id, title, description, "reserve")

    _user = db.query(UserModel).filter(UserModel.id == new_reserve[0].owner_id).first()

    email = _user.email or _user.company.alternative_email

    background_tasks.add_task(func=send_email, email=email, title=title, description=description)

    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
    }
'''

@reserve_router.post("/", status_code=201)
@rbac_access_checker(
    resource=RBACResource.reserve, rbac_access_type=RBACAccessType.create
)
async def reserve_cv(
    *,
    reserve_in: ReserveCreateSchema,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db_raw),
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Create a new reserve request.
    """
    user = context_actor_user_data.get()
    reserve_in.reserver_id = user.id

    reserve_repo = ReserveRepository(entity=ReserveModel)
    new_reserve = reserve_repo.send_reserve_request(db, obj_in=reserve_in)

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code

    # ✅ Handle empty reserve case to avoid IndexError
    if not new_reserve:
        return {
            "status_code": res_data.status_code,
            "message": res_data.message,
            "error": res_data.error,
        }

    for reserve in new_reserve:
        run_date = datetime.now(timezone.utc) + timedelta(hours=24)
        reminder_date = datetime.now(timezone.utc) + timedelta(hours=23)
        scheduler.add_job(delete_old_pending_reserve, 'date', run_date=run_date, args=[reserve.cv_id, db])
        scheduler.add_job(pending_reserves_notification, 'date', run_date=reminder_date, args=[reserve.cv_id, db])

    title = "Reserve Request"
    description = (
        "Your promoted profile(s) has been reserved. Please accept the reservation within 24 hours, "
        "or it will become available for reservation again."
    )

    background_tasks.add_task(send_notification, db, new_reserve[0].owner_id, title, description, "reserve")

    _user = db.query(UserModel).filter(UserModel.id == new_reserve[0].owner_id).first()
    email = _user.email or (_user.company.alternative_email if _user.company else None)

    if email:
        background_tasks.add_task(send_email, email=email, title=title, description=description)

    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
    }


@reserve_router.post("/my-not-reserves", status_code=200)
async def get_unreserved_employee_cvs(
    request: Request,
    response: Response,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10
):
    """
    Get all CVs that are not reserved by the current user
    """
    db = next(get_db_raw())
    user = context_actor_user_data.get()

    reserve_repo = ReserveRepository(entity=ReserveModel)
    reserver_repo = PromotionRepository(entity=PromotionPackagesModel)

    result = reserve_repo.get_not_reserved_by_me(db, user_id=user.id, skip=skip, limit=limit)
    #reserve = reserver_repo.get_all_promotions_filter(db,  skip=skip, limit=limit)
    return {
        "status_code": 200,
        "message": "Unreserved CVs fetched successfully",
        "error": None,
        "data": result["data"],
        #"data": reserve["data"],
        "count": result["count"],
    }


@reserve_router.post(
    "/paginated",
    response_model=GenericMultipleResponse[ReserveReadSchema],
    status_code=200,
)
# @rbac_access_checker(
#     resource=RBACResource.reserve, rbac_access_type=RBACAccessType.read_multiple
# )
async def view_reserves(
    *,
    filters: Optional[ReserveFilterSchema] = None,
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
    View paginated reserves
    """
    db = get_db_session()
    reserve_repo = ReserveRepository(entity=ReserveModel)
    reserves_read = reserve_repo.get_some(
        db,
        skip=skip,
        limit=limit,
        search=search,
        search_schema=UsersSearchSchema,
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
        "data": reserves_read,
        "count": res_data.count,
    }

from fastapi import Depends
from sqlalchemy.orm import Session

@reserve_router.get(
    "/all/employee/paginated",
    response_model=None,
    status_code=200,
)
async def view_all_active_promoted_employee_cvs(
    *,
    skip: int = 0,
    limit: int = 10,
    request: Request,
    response: Response,
    db: Session = Depends(get_db_sessions)
) -> Any:
    """
    View all CVs of actively promoted employees, no auth or filters required
    """
    reserve_repo = ReserveRepository(entity=ReserveModel)
    all_cvs = reserve_repo.get_all_active_promoted_employee_cvs(
        db=db,
        skip=skip,
        limit=limit
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": all_cvs,
        "count": res_data.count,
    }



@reserve_router.post(
    "/employee/paginated",
    response_model=None,
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.cv, rbac_access_type=RBACAccessType.read_multiple
)
async def view_filtered_employee_cvs(
    *,
    search: str = None,
    filters: Optional[ReserveCVFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10,
    request: Request,
    response: Response
) -> Any:
    """
    view filtered employee cvs
    """
    db = get_db_session()
    reserve_repo = ReserveRepository(entity=ReserveModel)
    filtered_reserves = reserve_repo.get_filtered_employee_cvs(
        db,
        skip=skip,
        limit=limit,
        filters=filters,
        search=search,
        search_schema=CVSearchSchema,
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": filtered_reserves,
        "count": res_data.count,
    }



@reserve_router.post(
    "/history",
    response_model=GenericMultipleResponse[BatchReserveReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.reserve, rbac_access_type=RBACAccessType.read_multiple
)
async def view_reserve_history(
    *,
    filters: Optional[ReserveFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10,
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve paginated reserve hisotry.
    """
    db = get_db_session()
    reserve_repo = ReserveRepository(entity=ReserveModel)
    reserves_read = reserve_repo.get_reserver_reserves(
        db,
        skip=skip,
        limit=limit,
        filters=filters,
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": reserves_read,
        "count": res_data.count,
    }


@reserve_router.post(
    "/my-reserves",
    # response_model=GenericMultipleResponse[ReserveReadSchema | BatchReserveReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.reserve, rbac_access_type=RBACAccessType.read_multiple
)
async def view_my_reserves(
    *,
    filters: Optional[ReserveFilterSchema] = None,
    # _=Depends(authentication_context),
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10
) -> Any:
    """
    Retrieve my received reserves
    """
    db = get_db_session()
    reserve_repo = ReserveRepository(entity=ReserveModel)
    reserves_read = reserve_repo.get_received_reserve_requests(
        db, skip=skip, limit=limit
    )

    data = []

    try:
        for reserve in reserves_read:
            data.append({
                "id": reserve.id,
                "reserver": {
                    "first_name": reserve.reserver.first_name,
                    "last_name": reserve.reserver.last_name,
                    "role": reserve.reserver.role,
                },
                "created_at": reserve.created_at,
                "updated_at": reserve.updated_at,
            })
    except Exception as e:
        logger.error(f"An error occurred: {e}")
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")

    return {"status_code": 200, "message": "Success", "error": False, "data": data}

@reserve_router.post(
    "/my-reserves/detail/paginated",
    # response_model=GenericMultipleResponse[ReserveReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.reserve, rbac_access_type=RBACAccessType.read_multiple
)
async def view_my_reserves_detail(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    batch_reserve_id: int,
) -> Any:
    """
    View paginated reserve requests received detail
    """
    db = get_db_session()
    reserve_repo = ReserveRepository(entity=ReserveModel)
    reserves_read = reserve_repo.get_received_reserve_requests_details(
        db,
        batch_reserve_id=batch_reserve_id,

    )
    data = []
    try:
        for reserve in reserves_read:
            data.append({
                "id": reserve.id,
                "cv_id": reserve.cv_id,
                "cv": {          
                    "id": reserve.cv.id,
                    "user_id": reserve.cv.user_id,
                    "date_of_birth": reserve.cv.date_of_birth,
                    "height": reserve.cv.height,
                    "weight": reserve.cv.weight,
                    "sex": reserve.cv.sex,
                    "skin_tone": reserve.cv.skin_tone,
                    "religion": reserve.cv.religion,
                    "marital_status": reserve.cv.marital_status,
                    "occupation": reserve.cv.occupation,
                    "nationality": reserve.cv.nationality,
                    "passport_number": reserve.cv.passport_number,
                    "english_full_name": reserve.cv.english_full_name,
                    "arabic_full_name": reserve.cv.arabic_full_name,
                    "amharic_full_name": reserve.cv.amharic_full_name,
                },
                "reason": reserve.reason,
                "status": reserve.status,
                "created_at": reserve.created_at,
            })
    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")
    
    return {"status_code": 200, "message": "Success", "error": False, "data": data}


@reserve_router.patch(
    "/", response_model=GenericMultipleResponse[ReserveReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.reserve, rbac_access_type=RBACAccessType.update
)
async def accept_decline_reserve(
    *,
    background_tasks: BackgroundTasks,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    reserve_update: ReserveUpdateSchema,
    request: Request,
    response: Response
) -> Any:
    """
    Update reserve status
    """
    try:
        db = get_db_session()
        reserve_repo = ReserveRepository(entity=ReserveModel)
        reserve_updated = reserve_repo.accept_decline_reserve_request(
            db, filter_obj_in=reserve_update.filter, obj_in=reserve_update.update
        )

        for reserve in reserve_updated:
            status = reserve.status.capitalize()
            name = ""

            if reserve.cv and reserve.cv.english_full_name:
                name = reserve.cv.english_full_name
            else:
                name = f"{reserve.first_name} {reserve.last_name}"

            if status == "accepted":
                title = f"Reserve Request {status}"
                description = f"Your reservation request has been successfully accepted. Please pay the reservation fee within 24 hours to access the full CV of the promoted profile."
            else:
                title = f"Reserve Request {status}"
                description = f"Your reserve request for {name} has been {status}"
           
            background_tasks.add_task(send_notification, db, reserve.reserver_id, title, description, "reserve")

            _user = db.query(UserModel).filter(UserModel.id == reserve.reserver_id).first()

            email = _user.email or _user.company.alternative_email

            background_tasks.add_task(func=send_email, email=email, title=title, description=description)

        res_data = context_set_response_code_message.get()
        response.status_code = res_data.status_code
        return {
            "status_code": res_data.status_code,
            "message": res_data.message,
            "error": res_data.error,
            "data": reserve_updated,
        }
    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")


@reserve_router.get("/recruitments")
async def get_recruitment_reserves(
    country: str | None = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context)
):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()

        if user.role != "sponsor":
            return Response(status_code=403, content=json.dumps({"message": "Forbidden"}), media_type="application/json")

        recruitments = db.query(UserModel).filter(UserModel.role == "recruitment").all()

        if country:
            recruitments = [
                recruitment for recruitment in recruitments 
                if recruitment.company and recruitment.company.location == country
            ]

        data = []

        for recruitment in recruitments:
            if recruitment.company:
                data.append({
                    "id": recruitment.id,
                    "name": f"{recruitment.first_name} {recruitment.last_name}",
                    "company": recruitment.company.company_name,
                    "location": recruitment.company.location
                })
        return {"data": data}

    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")


@reserve_router.post("/recruitment/create")
async def create_recruitment_reserve(
    data: RecruitmentReserveCreate,
    background_tasks: BackgroundTasks,
    _=Depends(authentication_context),
    __=Depends(build_request_context)
):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()

        if user.role != "sponsor":
            return Response(status_code=403, content=json.dumps({"message": "Forbidden"}), media_type="application/json")

        existing_reserve = db.query(RecruitmentReserveModel).filter(
            RecruitmentReserveModel.recruitment_id == data.recruitment_id,
            RecruitmentReserveModel.sponsor_id == user.id,
            RecruitmentReserveModel.employee_id == data.employee_id,
            RecruitmentReserveModel.status == "pending"
        ).first()

        if existing_reserve:
            return Response(
                status_code=400,
                content=json.dumps({"message": "A pending recruitment reserve with the same details already exists"}),
                media_type="application/json"
            )
        
        reserve = db.query(ReserveModel).filter(ReserveModel.owner_id == data.employee_id,
                                                 ReserveModel.reserver_id == user.id, ReserveModel.status == "paid").first()

        if not reserve:
            return Response(status_code=404, content=json.dumps({"message": "Opps! You have not reserved this employee"}), media_type="application/json")


        recruitment_reserve = RecruitmentReserveModel(
            recruitment_id=data.recruitment_id,
            sponsor_id=user.id,
            employee_id=data.employee_id,
            status="pending"
        )

        db.add(recruitment_reserve)

        db.commit()
        _user = db.query(UserModel).filter(UserModel.id == user.id).first()

        title = "Employee Process Request"
        description = f"{_user.first_name} {_user.last_name} has requested to process {reserve.cv.english_full_name}"

        background_tasks.add_task(send_notification, db, data.recruitment_id, title, description, "employee_process")

        _user = db.query(UserModel).filter(UserModel.id == data.recruitment_id).first()

        email = _user.email or _user.company.alternative_email

        background_tasks.add_task(send_email, email=email, title=title, description=description)

        return {"message": "Recruitment reserve created successfully"}
    except Exception as e:
        db.rollback()
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")


def create_invoice(db, ref: str, amount: float, user_id: uuid.UUID, recruitment_reserve_id: str) -> InvoiceModel:
    invoice = InvoiceModel(
        stripe_session_id=ref,
        status="pending",
        amount=amount,
        created_at=datetime.now(timezone.utc),
        type="employee_process",
        buyer_id=user_id,
        object_id=recruitment_reserve_id,
    )
    db.add(invoice)
    return invoice


def update_invoice(invoice: InvoiceModel, ref: str) -> None:
    invoice.stripe_session_id = ref


@reserve_router.get("/recruitment/payment/info/{recruitment_reserve_id}")
async def get_recruitment_payment_info(
    recruitment_reserve_id: int,
    _=Depends(authentication_context),
    __=Depends(build_request_context)
):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()

        if user.role != "recruitment":
            return Response(status_code=403, content=json.dumps({"message": "Forbidden"}), media_type="application/json")

        recruitment_reserve = db.query(RecruitmentReserveModel).filter(RecruitmentReserveModel.id == recruitment_reserve_id, RecruitmentReserveModel.recruitment_id == user.id).first()

        if not recruitment_reserve:
            return Response(status_code=404, content=json.dumps({"message": "Recruitment reserve not found"}), media_type="application/json")

        package = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.role == "recruitment", PromotionPackagesModel.category == "employee_process").first()

        if not package:
            return Response(status_code=404, content=json.dumps({"message": "Package not found"}), media_type="application/json")

        return {
            "price": package.price,
            "total_amount": package.price,
            "profile": 1
        }
    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")

@reserve_router.patch("/recruitment/status")
async def update_recruitment_reserve_status(
    data: RecruitmentReserveStatusUpdate,
    background_tasks: BackgroundTasks,
    _=Depends(authentication_context),
    __=Depends(build_request_context)
):
    db = get_db_session()
    user = context_actor_user_data.get()

    if user.role != "recruitment":
        return Response(status_code=403, content=json.dumps({"message": "Forbidden"}), media_type="application/json")

    recruitment_reserve = db.query(RecruitmentReserveModel).filter(RecruitmentReserveModel.id == data.id, RecruitmentReserveModel.recruitment_id == user.id).first()

    if not recruitment_reserve:
        return Response(status_code=404, content=json.dumps({"message": "Recruitment not found"}), media_type="application/json")

    if data.status == "declined":
        recruitment_reserve.status = "declined"

        db.commit()

        title = "Employee Process Request Declined"

        description = f"{recruitment_reserve.recruitment.first_name} {recruitment_reserve.recruitment.last_name} has declined to process {recruitment_reserve.employee.cv.english_full_name}"

        background_tasks.add_task(send_notification, db, recruitment_reserve.sponsor_id, title, description, "employee_process")

        email = recruitment_reserve.sponsor.email or recruitment_reserve.sponsor.company.company.alternative_email

        background_tasks.add_task(send_email, email=email, title=title, description=description)


        return {"message": "Recruitment reserve status updated successfully"}

    if data.status == "accepted":        
        package = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.role == "recruitment", PromotionPackagesModel.category == "employee_process").first()
        
        return_url = settings.TELR_EMPLOYEE_PROCESS_RETURN_URL.replace("replace", user.role)

        order_response = telr.order(
            order_id=f"ORDER{uuid.uuid4().hex[:8]}",
            amount=package.price,
            currency="AED",
            return_url=return_url,
            return_decl=return_url,
            return_can=return_url,
            description=f"{recruitment_reserve.employee.cv.english_full_name} Employee Process"
        )

        ref = order_response.get("order", {}).get("ref")

        if not ref:
            return Response(status_code=400, content=json.dumps({"message": "Failed to process payment"}), media_type="application/json")

        invoice = db.query(InvoiceModel).filter(
            InvoiceModel.object_id == str(recruitment_reserve.id),
            InvoiceModel.buyer_id == user.id,
            InvoiceModel.status == "pending",
            InvoiceModel.type == "employee_process"
        ).first()

        if invoice:
            update_invoice(invoice, ref)
        else:
            invoice = create_invoice(db, ref, package.price, user.id, recruitment_reserve.id)
            db.add(invoice)

        db.commit()

        return {
            "method": order_response.get("method"),
            "trace": order_response.get("trace"),
            "order": {
                "ref": order_response.get("order", {}).get("ref"),
                "url": order_response.get("order", {}).get("url"),
            },
        }



@reserve_router.patch("/recruitment/sponsor/status")
async def update_recruitment_spnsor_reserve_status(
    data: RecruitmentReserveStatusUpdate,
    background_tasks: BackgroundTasks,
    _=Depends(authentication_context),
    __=Depends(build_request_context)
):
    db = get_db_session()
    user = context_actor_user_data.get()

    if user.role != "recruitment":
        return Response(status_code=403, content=json.dumps({"message": "Forbidden"}), media_type="application/json")

    recruitment_reserve = db.query(RecruitmentReserveModel).filter(RecruitmentReserveModel.id == data.id, RecruitmentReserveModel.recruitment_id == user.id).first()

    if not recruitment_reserve:
        return Response(status_code=404, content=json.dumps({"message": "Recruitment not found"}), media_type="application/json")

    if data.status == "declined":
        recruitment_reserve.status = "declined"

        db.commit()

        title = "Employee Process Request Declined"

        description = f"{recruitment_reserve.recruitment.first_name} {recruitment_reserve.recruitment.last_name} has declined to process {recruitment_reserve.employee.cv.english_full_name}"

        background_tasks.add_task(send_notification, db, recruitment_reserve.sponsor_id, title, description, "employee_process")

        email = recruitment_reserve.sponsor.email or recruitment_reserve.sponsor.company.company.alternative_email

        background_tasks.add_task(send_email, email=email, title=title, description=description)


        return {"message": "Recruitment reserve status updated successfully"}

    if data.status == "accepted":        
        package = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.role == "recruitment", PromotionPackagesModel.category == "employee_process").first()
        
        return_url = settings.TELR_SPONSOR_EMPLOYEE_PROCESS_RETURN_URL.replace("replace", user.role)

        order_response = telr.order(
            order_id=f"ORDER{uuid.uuid4().hex[:8]}",
            amount=package.price,
            currency="AED",
            return_url=return_url,
            return_decl=return_url,
            return_can=return_url,
            description=f"{recruitment_reserve.employee.cv.english_full_name} Employee Process"
        )

        ref = order_response.get("order", {}).get("ref")

        if not ref:
            return Response(status_code=400, content=json.dumps({"message": "Failed to process payment"}), media_type="application/json")

        invoice = db.query(InvoiceModel).filter(
            InvoiceModel.object_id == str(recruitment_reserve.id),
            InvoiceModel.buyer_id == user.id,
            InvoiceModel.status == "pending",
            InvoiceModel.type == "employee_process"
        ).first()

        if invoice:
            update_invoice(invoice, ref)
        else:
            invoice = create_invoice(db, ref, package.price, user.id, recruitment_reserve.id)
            db.add(invoice)

        db.commit()

        return {
            "method": order_response.get("method"),
            "trace": order_response.get("trace"),
            "order": {
                "ref": order_response.get("order", {}).get("ref"),
                "url": order_response.get("order", {}).get("url"),
            },
        }



'''
@reserve_router.post("/recruitment/status/callback")
async def update_recruitment_reserve_status_callback(data: TransferRequestPaymentCallback, background_tasks: BackgroundTasks, _=Depends(authentication_context),__=Depends(build_request_context)):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()
        status_response = telr.status(
                order_reference = data.ref
        )
        state = status_response.get("order").get("status").get("text")
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
            InvoiceModel.type == "employee_process"
        ).first()
        if not invoice:
            return Response(status_code=404, content=json.dumps({"message": "Invoice not found"}), media_type="application/json")
        recruitment_reserve = db.query(RecruitmentReserveModel).filter(RecruitmentReserveModel.id == invoice.object_id).first()
        if not recruitment_reserve:
            return Response(status_code=404, content=json.dumps({"message": "Recruitment reserve not found"}), media_type="application/json")
        invoice.status = "paid"
        invoice.card = card_type
        invoice.description = description
        recruitment_reserve.status = "accepted"
        db.add(recruitment_reserve)
        db.add(invoice)
        db.commit()
        title = "Employee Process Request Accepted"
        description = f"{recruitment_reserve.recruitment.first_name} {recruitment_reserve.recruitment.last_name} has accepted to process {recruitment_reserve.employee.cv.english_full_name}"
        background_tasks.add_task(send_notification, db, recruitment_reserve.sponsor_id, title, description, "employee_process")
        email = recruitment_reserve.sponsor.email or recruitment_reserve.sponsor.company.company.alternative_email
        background_tasks.add_task(send_email, email=email, title=title, description=description)
        return {"status": "success", "message": "Payment successful"}
    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")
'''

@reserve_router.post("/recruitment/status/callback")
async def update_recruitment_reserve_status_callback(data: TransferRequestPaymentCallback, background_tasks: BackgroundTasks, _=Depends(authentication_context),__=Depends(build_request_context)):
    try:
        logger.info(f"Received recruitment status callback for reference: {data.ref}")
        db = get_db_session()
        user = context_actor_user_data.get()
        
        try:
            status_response = telr.status(
                order_reference = data.ref
            )
            logger.debug(f"Telr status response: {status_response}")
        except Exception as e:
            logger.error(f"Failed to get status from Telr: {str(e)}", exc_info=True)
            return Response(
                status_code=500,
                content=json.dumps({"message": "Failed to verify payment status"}),
                media_type="application/json"
            )

        state = status_response.get("order", {}).get("status", {}).get("text")
        error = status_response.get("error", {})
        card_type = status_response.get("order", {}).get("card", {}).get("type")
        description = status_response.get("order", {}).get("description")

        if error:
            logger.error(f"Payment error: {error}")
            return Response(
                status_code=400,
                content=json.dumps({"message": error.get("note", "Failed to process payment")}),
                media_type="application/json"
            )

        if state.lower() == "pending":
            logger.info(f"Payment is pending for reference: {data.ref}")
            return Response(
                status_code=400,
                content=json.dumps({"message": "Payment is pending"}),
                media_type="application/json"
            )

        try:
            invoice = db.query(InvoiceModel).filter(
                InvoiceModel.stripe_session_id == data.ref,
                InvoiceModel.buyer_id == user.id,
                InvoiceModel.status == "pending",
                InvoiceModel.type == "employee_process"
            ).first()

            if not invoice:
                logger.error(f"Invoice not found for reference: {data.ref}")
                return Response(
                    status_code=404,
                    content=json.dumps({"message": "Invoice not found"}),
                    media_type="application/json"
                )

            recruitment_reserve = db.query(RecruitmentReserveModel).filter(
                RecruitmentReserveModel.id == invoice.object_id
            ).first()

            if not recruitment_reserve:
                logger.error(f"Recruitment reserve not found for invoice: {invoice.id}")
                return Response(
                    status_code=404,
                    content=json.dumps({"message": "Recruitment reserve not found"}),
                    media_type="application/json"
                )

            # Update invoice and recruitment reserve status
            invoice.status = "paid"
            invoice.card = card_type
            invoice.description = description
            recruitment_reserve.status = "accepted"

            db.add(recruitment_reserve)
            db.add(invoice)
            db.commit()

            logger.info(f"Successfully updated invoice {invoice.id} and recruitment reserve {recruitment_reserve.id}")

            # Send notifications
            title = "Employee Process Request Accepted"
            description = f"{recruitment_reserve.recruitment.first_name} {recruitment_reserve.recruitment.last_name} has accepted to process {recruitment_reserve.employee.cv.english_full_name}"
            
            try:
                background_tasks.add_task(send_notification, db, recruitment_reserve.sponsor_id, title, description, "employee_process")
                email = recruitment_reserve.sponsor.email or recruitment_reserve.sponsor.company.company.alternative_email
                background_tasks.add_task(send_email, email=email, title=title, description=description)
                logger.info(f"Successfully added notification tasks for recruitment reserve {recruitment_reserve.id}")
            except Exception as e:
                logger.error(f"Failed to add notification tasks: {str(e)}", exc_info=True)
                # Continue execution as notifications are not critical

            return {"status": "success", "message": "Payment successful"}

        except Exception as e:
            logger.error(f"Database operation failed: {str(e)}", exc_info=True)
            db.rollback()
            return Response(
                status_code=500,
                content=json.dumps({"message": "Failed to process payment"}),
                media_type="application/json"
            )

    except Exception as e:
        logger.error(f"Unexpected error in recruitment status callback: {str(e)}", exc_info=True)
        return Response(
            status_code=500,
            content=json.dumps({"message": "An unexpected error occurred"}),
            media_type="application/json"
        )
'''
@reserve_router.get("/recruitment/detail")
async def get_recruitment_reserve_detail(
    recruitment_reserve_id: int,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()

        _user = db.query(UserModel).filter(UserModel.id == user.id).first()

        if _user.role == "recruitment":
            recruitment_reserve = db.query(RecruitmentReserveModel).filter(RecruitmentReserveModel.id == recruitment_reserve_id, RecruitmentReserveModel.status == "accepted").first()
            if not recruitment_reserve:
                return Response(status_code=404, content=json.dumps({"message": "Sponsor not found"}), media_type="application/json")
            
            return {
                "phone_number": recruitment_reserve.sponsor.phone_number,
                "company_name": recruitment_reserve.sponsor.company.company_name,
                "name": f"{recruitment_reserve.sponsor.first_name} {recruitment_reserve.sponsor.last_name}",
                "email": recruitment_reserve.sponsor.email,
            }

        if _user.role == "sponsor":
            recruitment_reserve = db.query(RecruitmentReserveModel).filter(RecruitmentReserveModel.id == recruitment_reserve_id, RecruitmentReserveModel.status == "accepted").first()
            if not recruitment_reserve:
                return Response(status_code=404, content=json.dumps({"message": "Sponsor not found"}), media_type="application/json")

            return {
                "phone_number": recruitment_reserve.recruitment.phone_number,
                "company_name": recruitment_reserve.recruitment.company.company_name,
                "name": f"{recruitment_reserve.recruitment.first_name} {recruitment_reserve.recruitment.last_name}",
                "email": recruitment_reserve.recruitment.email,
            }

    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")
'''
'''
@reserve_router.get("/recruitment/detail")
async def get_recruitment_reserve_detail(
    recruitment_reserve_id: int,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    try:
        logger.info(f"Fetching recruitment reserve detail for ID: {recruitment_reserve_id}")
        db = get_db_session()
        user = context_actor_user_data.get()

        try:
            _user = db.query(UserModel).filter(UserModel.id == user.id).first()
            if not _user:
                logger.error(f"User not found for ID: {user.id}")
                return Response(
                    status_code=404,
                    content=json.dumps({"message": "User not found"}),
                    media_type="application/json"
                )

            logger.debug(f"User role: {_user.role}")

            if _user.role == "recruitment":
                logger.info(f"Fetching sponsor details for recruitment user {user.id}")
                recruitment_reserve = db.query(RecruitmentReserveModel).filter(
                    RecruitmentReserveModel.id == recruitment_reserve_id,
                    RecruitmentReserveModel.status == "accepted"
                ).first()

                if not recruitment_reserve:
                    logger.error(f"Recruitment reserve not found for ID: {recruitment_reserve_id}")
                    return Response(
                        status_code=404,
                        content=json.dumps({"message": "Recruitment reserve not found"}),
                        media_type="application/json"
                    )

                logger.info(f"Successfully retrieved sponsor details for recruitment reserve {recruitment_reserve_id}")
                return {
                    "phone_number": recruitment_reserve.sponsor.phone_number,
                    "company_name": recruitment_reserve.sponsor.company.company_name,
                    "name": f"{recruitment_reserve.sponsor.first_name} {recruitment_reserve.sponsor.last_name}",
                    "email": recruitment_reserve.sponsor.email,
                }

            if _user.role == "sponsor":
                logger.info(f"Fetching recruitment details for sponsor user {user.id}")
                recruitment_reserve = db.query(RecruitmentReserveModel).filter(
                    RecruitmentReserveModel.id == recruitment_reserve_id,
                    RecruitmentReserveModel.status == "accepted"
                ).first()

                if not recruitment_reserve:
                    logger.error(f"Recruitment reserve not found for ID: {recruitment_reserve_id}")
                    return Response(
                        status_code=404,
                        content=json.dumps({"message": "Recruitment reserve not found"}),
                        media_type="application/json"
                    )

                logger.info(f"Successfully retrieved recruitment details for recruitment reserve {recruitment_reserve_id}")
                return {
                    "phone_number": recruitment_reserve.recruitment.phone_number,
                    "company_name": recruitment_reserve.recruitment.company.company_name,
                    "name": f"{recruitment_reserve.recruitment.first_name} {recruitment_reserve.recruitment.last_name}",
                    "email": recruitment_reserve.recruitment.email,
                }

            logger.error(f"Invalid user role: {_user.role}")
            return Response(
                status_code=403,
                content=json.dumps({"message": "Invalid user role"}),
                media_type="application/json"
            )

        except Exception as e:
            logger.error(f"Database operation failed: {str(e)}", exc_info=True)
            return Response(
                status_code=500,
                content=json.dumps({"message": "Failed to fetch recruitment reserve details"}),
                media_type="application/json"
            )

    except Exception as e:
        logger.error(f"Unexpected error in get_recruitment_reserve_detail: {str(e)}", exc_info=True)
        return Response(
            status_code=500,
            content=json.dumps({"message": "An unexpected error occurred"}),
            media_type="application/json"
        )

'''
@reserve_router.get("/recruitment/detail")
async def get_recruitment_reserve_detail(
    recruitment_reserve_id: int,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    try:
        logger.info(f"Fetching recruitment reserve detail for ID: {recruitment_reserve_id}")
        db = get_db_session()
        user = context_actor_user_data.get()

        try:
            _user = db.query(UserModel).filter(UserModel.id == user.id).first()
            if not _user:
                logger.error(f"User not found for ID: {user.id}")
                return Response(
                    status_code=404,
                    content=json.dumps({"message": "User not found"}),
                    media_type="application/json"
                )

            logger.debug(f"User role: {_user.role}")

            if _user.role == "recruitment":
                logger.info(f"Fetching sponsor details for recruitment user {user.id}")
                recruitment_reserve = db.query(RecruitmentReserveModel).filter(
                    RecruitmentReserveModel.id == recruitment_reserve_id,
                    RecruitmentReserveModel.status == "accepted"
                ).first()

                if not recruitment_reserve:
                    logger.error(f"Recruitment reserve not found for ID: {recruitment_reserve_id}")
                    return Response(
                        status_code=404,
                        content=json.dumps({"message": "Recruitment reserve not found"}),
                        media_type="application/json"
                    )

                # Safely get sponsor details with null checks
                sponsor = recruitment_reserve.sponsor
                company = sponsor.company if sponsor else None
                
                logger.info(f"Successfully retrieved sponsor details for recruitment reserve {recruitment_reserve_id}")
                return {
                    "phone_number": sponsor.phone_number if sponsor else None,
                    "company_name": company.company_name if company else None,
                    "name": f"{sponsor.first_name} {sponsor.last_name}".strip() if sponsor else None,
                    "email": sponsor.email if sponsor else None,
                }

            if _user.role == "sponsor":
                logger.info(f"Fetching recruitment details for sponsor user {user.id}")
                recruitment_reserve = db.query(RecruitmentReserveModel).filter(
                    RecruitmentReserveModel.id == recruitment_reserve_id,
                    RecruitmentReserveModel.status == "accepted"
                ).first()

                if not recruitment_reserve:
                    logger.error(f"Recruitment reserve not found for ID: {recruitment_reserve_id}")
                    return Response(
                        status_code=404,
                        content=json.dumps({"message": "Recruitment reserve not found"}),
                        media_type="application/json"
                    )

                # Safely get recruitment details with null checks
                recruitment = recruitment_reserve.recruitment
                company = recruitment.company if recruitment else None
                
                logger.info(f"Successfully retrieved recruitment details for recruitment reserve {recruitment_reserve_id}")
                return {
                    "phone_number": recruitment.phone_number if recruitment else None,
                    "company_name": company.company_name if company else None,
                    "name": f"{recruitment.first_name} {recruitment.last_name}".strip() if recruitment else None,
                    "email": recruitment.email if recruitment else None,
                }

            logger.error(f"Invalid user role: {_user.role}")
            return Response(
                status_code=403,
                content=json.dumps({"message": "Invalid user role"}),
                media_type="application/json"
            )

        except Exception as e:
            logger.error(f"Database operation failed: {str(e)}", exc_info=True)
            return Response(
                status_code=500,
                content=json.dumps({"message": "Failed to fetch recruitment reserve details"}),
                media_type="application/json"
            )

    except Exception as e:
        logger.error(f"Unexpected error in get_recruitment_reserve_detail: {str(e)}", exc_info=True)
        return Response(
            status_code=500,
            content=json.dumps({"message": "An unexpected error occurred"}),
            media_type="application/json"
        )     
'''
@reserve_router.get("/recruitment/income", response_model=list[RecruitmentReserveReadSchema])
async def get_recruitment_income(
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()
        recruitment_reserves = db.query(RecruitmentReserveModel).filter(RecruitmentReserveModel.recruitment_id == user.id).all()
        if not recruitment_reserves:
            return Response(status_code=404, content=json.dumps({"message": "Recruitment reserves not found"}), media_type="application/json")
        return recruitment_reserves
    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")
'''

@reserve_router.get("/recruitment/income", response_model=list[RecruitmentReserveReadSchema])
async def get_recruitment_income(
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()
        recruitment_reserves = db.query(RecruitmentReserveModel).filter(RecruitmentReserveModel.recruitment_id == user.id).all()
        return recruitment_reserves or []
    except Exception as e:
        logger.error(f"Error in get_recruitment_income: {str(e)}", exc_info=True)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")

'''

@reserve_router.get("/recruitment/process", response_model=list[RecruitmentReserveReadSchema])
async def get_recruitment_process(
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    try:
        db = get_db_session()

        user = context_actor_user_data.get()

        recruitment_reserves = db.query(RecruitmentReserveModel).filter(RecruitmentReserveModel.sponsor_id == user.id).all()
        
        if not recruitment_reserves:
            return Response(status_code=404, content=json.dumps({"message": "Recruitment reserves not found"}), media_type="application/json")


        return recruitment_reserves
    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")

'''
@reserve_router.get("/recruitment/process", response_model=list[RecruitmentReserveReadSchema])
async def get_recruitment_process(
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()
        recruitment_reserves = db.query(RecruitmentReserveModel).filter(RecruitmentReserveModel.sponsor_id == user.id).all()
        return recruitment_reserves or []
    except Exception as e:
        logger.error(f"Error in get_recruitment_process: {str(e)}", exc_info=True)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")
    
@reserve_router.post("/info")
async def reserve_info(
    data: ReservePay,
    _=Depends(authentication_context),
    __=Depends(build_request_context),

):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()

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

        amount = package.price * len(reservations)


        return {
            "price": package.price,
            "total_amount": amount,
            "profile": len(reservations)
        }

    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")

'''
@reserve_router.get("/company/info/{reserve_batch_id}")
async def reserve_company_info(
    reserve_batch_id: int,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()

        if user.role != "employee":
            return Response(status_code=403, content=json.dumps({"message": "Forbidden"}), media_type="application/json")

        reserve_batch = db.query(BatchReserveModel).filter(BatchReserveModel.id == reserve_batch_id).first()

        if not reserve_batch:
            return Response(status_code=404, content=json.dumps({"message": "Reserve batch not found"}), media_type="application/json")
 
        if not reserve_batch.reserves or len(reserve_batch.reserves) == 0:
            return Response(status_code=404, content=json.dumps({"message": "Reserves not found"}), media_type="application/json")

        reserve_request = reserve_batch.reserves[0]

        if reserve_request.owner_id != user.id:
            return Response(status_code=403, content=json.dumps({"message": "Oops! You are not the owner of this reserve request"}), media_type="application/json")

        return {
            "batch_id": reserve_batch.id,
            "reserve_id": reserve_request.id,
            "company_name": reserve_request.reserver.company.company_name,
            "name": f"{reserve_request.reserver.first_name} {reserve_request.reserver.last_name}",
            "status": reserve_request.status,
            "reason": reserve_request.reason,
            "cv_id": reserve_request.owner.cv.id
        }

    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")


'''


from sqlalchemy.orm import joinedload
from fastapi import Depends, Response

@reserve_router.get("/company/info/{reserve_batch_id}")
async def reserve_company_info(
    reserve_batch_id: int,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    try:
        logger.info(f"Starting reserve_company_info for batch_id: {reserve_batch_id}")
        db = get_db_session()
        user = context_actor_user_data.get()
        logger.info(f"User {user.id} (role: {user.role}) requesting company info")
        ''''
        if user.role != "employee":
            logger.warning(f"User {user.id} with role {user.role} attempted to access employee-only endpoint")
            return Response(status_code=403, content=json.dumps({"message": "Forbidden"}), media_type="application/json")
        '''
        reserve_batch = (
            db.query(BatchReserveModel)
            .options(
                joinedload(BatchReserveModel.reserves)
                .joinedload(ReserveModel.reserver)
                .joinedload(UserModel.company),
                joinedload(BatchReserveModel.reserves)
                .joinedload(ReserveModel.owner)
                .joinedload(UserModel.cv)
            )
            .filter(BatchReserveModel.id == reserve_batch_id)
            .first()
        )

        if not reserve_batch:
            logger.warning(f"Reserve batch {reserve_batch_id} not found")
            return Response(status_code=404, content=json.dumps({"message": "Reserve batch not found"}), media_type="application/json")
 
        if not reserve_batch.reserves or len(reserve_batch.reserves) == 0:
            logger.warning(f"No reserves found for batch {reserve_batch_id}")
            return Response(status_code=404, content=json.dumps({"message": "Reserves not found"}), media_type="application/json")

        reserve_request = reserve_batch.reserves[0]
        logger.info(f"Processing reserve request {reserve_request.id}")

        if reserve_request.owner_id != user.id:
            logger.warning(f"User {user.id} attempted to access reserve request owned by {reserve_request.owner_id}")
            return Response(status_code=403, content=json.dumps({"message": "Oops! You are not the owner of this reserve request"}), media_type="application/json")

        # Build response with null values for missing data
        response_data = {
            "batch_id": reserve_batch.id,
            "reserve_id": reserve_request.id,
            "company_name": reserve_request.reserver.company.company_name if reserve_request.reserver.company else None,
            "name": f"{reserve_request.reserver.first_name} {reserve_request.reserver.last_name}" if reserve_request.reserver.first_name and reserve_request.reserver.last_name else None,
            "status": reserve_request.status,
            "reason": reserve_request.reason,
            "cv_id": reserve_request.owner.cv.id if reserve_request.owner and reserve_request.owner.cv else None
        }

        logger.info(f"Successfully processed request for batch {reserve_batch_id}")
        return response_data

    except Exception as e:
        logger.error(f"Error in reserve_company_info for batch {reserve_batch_id}: {str(e)}", exc_info=True)
        return Response(status_code=400, content=json.dumps({"message": "An error occurred"}), media_type="application/json")