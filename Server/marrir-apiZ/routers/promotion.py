import json
import pprint
from typing import Any, Optional
import uuid
from fastapi import APIRouter, Depends, Response, BackgroundTasks
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.companyinfomodel import CompanyInfoModel
from models.cvmodel import CVModel
from models.db import authentication_context, build_request_context, get_db_session
from models.employeemodel import EmployeeModel
from models.invoicemodel import InvoiceModel
from models.notificationmodel import Notifications
from models.promotionmodel import PromotionModel, PromotionSubscriptionModel
from models.usermodel import UserModel
from repositories.promotion import PromotionRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message, context_actor_user_data
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.cvschema import CVSearchSchema
from schemas.promotionschema import (
    BuyPromotionPackage,
    PromotionCreate,
    PromotionCreateSchema,
    PromotionFilterSchema,
    PromotionPackageUpdateSchema,
    PromotionReadSchema,
)
from schemas.reserveschema import ReserveCVFilterSchema
from schemas.promotionschema import PromotionPackageCreateSchema
from models.promotionmodel import PromotionPackagesModel
from datetime import datetime, timedelta, timezone
from telr_payment.api import Telr
from core.security import settings
import logging

from schemas.transferschema import TransferRequestPaymentCallback
from schemas.userschema import UserTokenSchema
from utils.send_email import send_email

logger = logging.getLogger(__name__)

telr = Telr(auth_key=settings.TELR_AUTH_KEY, store_id=settings.TELR_STORE_ID, test=settings.TELR_TEST_MODE)

promotion_router_prefix = version_prefix + "promotion"

promotion_router = APIRouter(prefix=promotion_router_prefix)

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



@promotion_router.patch(
    "/",
    response_model=GenericSingleResponse[PromotionReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.promotion, rbac_access_type=RBACAccessType.update
)
async def cancel_promotion(
    *,
    filter: PromotionFilterSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
):
    """
    cancel a promotion
    """
    db = get_db_session()
    promotion_repo = PromotionRepository(entity=PromotionModel)
    promotion_cancelled = promotion_repo.cancel_promotion(db=db, filter=filter)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": promotion_cancelled,
    }


@promotion_router.post("/", response_model=None, status_code=201)
@rbac_access_checker(
    resource=RBACResource.promotion, rbac_access_type=RBACAccessType.create
)
async def activate_promotion(
    *,
    promotion_in: PromotionCreateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    activate promotion
    """
    db = get_db_session()
    promotion_repo = PromotionRepository(entity=PromotionModel)
    activate_promotion = promotion_repo.activate_promotion(db, obj_in=promotion_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return


@promotion_router.post(
    "/paginated",
    response_model=GenericMultipleResponse[PromotionReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.promotion, rbac_access_type=RBACAccessType.read_multiple
)
async def read_promotions(
    *,
    filters: Optional[PromotionFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10,
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve paginated promotions.
    """
    db = get_db_session()
    promotion_repo = PromotionRepository(entity=PromotionModel)
    promotions_read = promotion_repo.promotion_history(
        db, skip=skip, limit=limit, filters=filters
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": promotions_read,
        "count": res_data.count,
    }


@promotion_router.post(
    "/admin/paginated",
    response_model=GenericMultipleResponse[PromotionReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.promotion, rbac_access_type=RBACAccessType.read_multiple
)
async def admin_read_all_promotions(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10,
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve paginated promotions for all users.
    """
    db = get_db_session()
    promotion_repo = PromotionRepository(entity=PromotionModel)
    promotions_read = promotion_repo.get_all_promotions(db, skip=skip, limit=limit)
    print(promotions_read, "READ")
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": promotions_read,
        "count": res_data.count,
    }


@promotion_router.post(
    "/cv/paginated",
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
    promotion_repo = PromotionRepository(entity=PromotionModel)
    filtered_promotions = promotion_repo.get_filtered_employee_cvs(
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
        "data": filtered_promotions,
        "count": res_data.count,
    }

def create_invoice(db, ref: str, amount: float, user_id: int, subscription_id: int) -> InvoiceModel:
    invoice = InvoiceModel(
        stripe_session_id=ref,
        status="pending",
        amount=amount,
        created_at=datetime.now(timezone.utc),
        type="promotion",
        buyer_id=user_id,
        object_id=subscription_id,
    )
    db.add(invoice)
    return invoice

def update_invoice(invoice: InvoiceModel, ref: str) -> None:
    invoice.stripe_session_id = ref


@promotion_router.get("/packages")
async def get_all_promotion_packages(
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    promotions = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.role == user.role, PromotionPackagesModel.category == "promotion").all()

    print(PromotionPackagesModel.category == "promotion")

    promotion_data = []

    for promotion in promotions:
        promotion_data.append(
            {
                "id": promotion.id,
                "role": promotion.role,
                "duration": promotion.duration,
                "profile_count": promotion.profile_count,
                "price": promotion.price,
                "category": promotion.category
            }
        )
    

    return {"data": promotion_data}


@promotion_router.post("/packages")
async def buy_promotion_package(
    data: BuyPromotionPackage,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()
    # Check if the user role is correct with the package role, don't use repository
    package = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.id == data.id, PromotionPackagesModel.role == user.role, PromotionPackagesModel.category == "promotion").first()

    if not package:
        return {"message": "Invalid package"}

    if package.duration.value == "1 month":
        end_date = datetime.now(timezone.utc) + timedelta(days=30)
    if package.duration.value == "3 months":
        end_date = datetime.now(timezone.utc) + timedelta(days=90)
    if package.duration.value == "6 months":
        end_date = datetime.now(timezone.utc) + timedelta(days=180)
    if package.duration.value == "12 months":
        end_date = datetime.now(timezone.utc) + timedelta(days=365)

    subscription = db.query(PromotionSubscriptionModel).filter(PromotionSubscriptionModel.user_id == user.id, PromotionSubscriptionModel.status == "active").first()

    if not subscription:

        in_active_subscription = db.query(PromotionSubscriptionModel).filter(PromotionSubscriptionModel.user_id == user.id, PromotionSubscriptionModel.status == "inactive").first()

        if in_active_subscription:
            in_active_subscription.current_profile_count = package.profile_count
            in_active_subscription.package_id = package.id
            in_active_subscription.status = "inactive"
            subscription = in_active_subscription
            subscription.start_date = datetime.now(timezone.utc)
            subscription.end_date = end_date

        else:
            subscription = PromotionSubscriptionModel(
                user_id=user.id,
                package_id=package.id,
                status="inactive",
                current_profile_count=package.profile_count,
                start_date=datetime.now(timezone.utc),
                end_date=end_date
            )

        try:
            db.add(subscription)
            db.commit()
        except Exception as e:
            return Response(status_code=400, content=json.dumps({"message": str(e)}), media_type="application/json")

    else:
        subscription.current_profile_count = package.profile_count
        subscription.package_id = package.id
        subscription.status = "inactive"
        subscription.start_date = datetime.now(timezone.utc)
        subscription.end_date = end_date

        try:
            db.commit()
        except Exception as e:
            return Response(status_code=400, content=json.dumps({"message": str(e)}), media_type="application/json")

    return_url = settings.TELR_PROMOTION_RETURN_URL.replace("replace", user.role)

    order_response = telr.order(
        order_id=f"ORDER{uuid.uuid4().hex[:8]}",
        amount=package.price,
        currency="AED",
        return_url=return_url,
        return_decl=return_url,
        return_can=return_url,
        description="Buy promotion package",
    )

    ref = order_response.get("order", {}).get("ref")

    if not ref:
        return Response(status_code=400, content=json.dumps({"message": "Failed to process payment"}), media_type="application/json")

    invoice = db.query(InvoiceModel).filter(
        InvoiceModel.object_id == str(subscription.id),
        InvoiceModel.buyer_id == user.id,
        InvoiceModel.status == "pending",
        InvoiceModel.type == "promotion"
    ).first()

    try:
        if invoice:
            update_invoice(invoice, ref)
        else:
            invoice = create_invoice(db, ref, package.price, user.id, subscription.id)
            db.add(invoice)
        db.commit()
    except Exception as e:
        logger.error(f"Failed to process invoice: {e}")
        db.rollback()
        return Response(status_code=400, content=json.dumps({"message": "Failed to process payment"}), media_type="application/json")

    return {
        "method": order_response.get("method"),
        "trace": order_response.get("trace"),
        "order": {
            "ref": order_response.get("order", {}).get("ref"),
            "url": order_response.get("order", {}).get("url"),
        },
    }


@promotion_router.post("/packages/callback")
async def buy_promotion_package_callback(data: TransferRequestPaymentCallback, background_tasks: BackgroundTasks, _=Depends(authentication_context),__=Depends(build_request_context)):
    db = get_db_session()

    user = context_actor_user_data.get()
    status_response = telr.status(
            order_reference = data.ref
    )
    
    state = status_response.get("order").get("status").get("text")

    card_type = status_response.get("order", {}).get("card", {}).get("type")

    description = status_response.get("order", {}).get("description")
    
    if state.lower()  == "pending":
        return Response(status_code=400, content=json.dumps({"message": "Payment is still pending"}), media_type="application/json")

    invoice = db.query(InvoiceModel).filter(
        InvoiceModel.stripe_session_id == data.ref,
        InvoiceModel.buyer_id == user.id,
        InvoiceModel.status == "pending",
        InvoiceModel.type == "promotion"
    ).first()

    subscription = db.query(PromotionSubscriptionModel).filter(PromotionSubscriptionModel.id == invoice.object_id, PromotionSubscriptionModel.status == "inactive", PromotionSubscriptionModel.user_id == user.id).first()

    invoice.status = "paid"
    invoice.card = card_type
    invoice.description = description
    subscription.status = "active"
    
    title = "Promotion package purchased"

    description = f"You've successfully bought a {subscription.package.duration.value.replace(' ', '-')} promotion package for {subscription.package.price} AED. You can now promote up to {subscription.current_profile_count} profiles until {subscription.end_date.strftime('%d %B %Y')}. Start promoting now."

    background_tasks.add_task(send_notification, db, user.id, title, description, "package")

    _user = db.query(UserModel).filter(UserModel.id == user.id).first()

    admins = db.query(UserModel).filter(UserModel.role == "admin").all()

    email = _user.email or _user.company.alternative_email

    background_tasks.add_task(send_email, email=email, title=title, description=description)

    for admin in admins:
        title = "Package purchased"
        description = f"{_user.role}: {_user.first_name} {_user.last_name} has successfully purchased a {subscription.package.duration.value.replace(' ', '-')} promotion package for {subscription.package.price} AED. The promotion will be valid until {subscription.end_date.strftime('%d %B %Y')}."
        background_tasks.add_task(send_notification, db, admin.id, title, description, "package")

    try:
        db.commit()
        return {"status": "success", "message": "Payment successful"}
    except Exception as e:
        print(e)
        db.rollback()
        return Response(status_code=500, content=json.dumps({"message": "Failed to process payment"}), media_type="application/json")

'''
@promotion_router.patch("/admin/packages")
async def update_promotion_package(
    data: PromotionPackageUpdateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    promotion = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.id == data.id).first()

    if not promotion:
        return Response(status_code=404, content=json.dumps({"message": "Promotion package not found"}), media_type="application/json")

    if data.category:
        promotion.category = data.category.name
    if data.role:
        promotion.role = data.role.name
    if data.duration:
        promotion.duration = data.duration.name
    if data.profile_count:
        promotion.profile_count = data.profile_count
    if data.price:
        promotion.price = data.price
    try:
        db.add(promotion)
        db.commit()
        return {"message": "Promotion package updated successfully"}
    except Exception as e:
        print(e)
        db.rollback()
        return Response(status_code=400, content=json.dumps({"message": "Failed to update promotion package"}), media_type="application/json")
'''
@promotion_router.get("/packages/subscriptions")
async def get_user_promotion_subscriptions(
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    subscription = db.query(PromotionSubscriptionModel).filter(PromotionSubscriptionModel.user_id == user.id, PromotionSubscriptionModel.status == "active").first()

    if not subscription:
        return {"message": "No active subscriptions"}
    
    return {
        "id": subscription.id,
        "status": subscription.status,
        "start_date": subscription.start_date,
        "end_date": subscription.end_date,
        "current_profile_count": subscription.current_profile_count
    }

@promotion_router.get("/my")
async def get_user_promotion(
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()
    promotions = db.query(PromotionModel).filter(PromotionModel.promoted_by_id == user.id).all()

    if not promotions:
        return Response(status_code=404, content=json.dumps({"message": "No promotion found"}), media_type="application/json")
    data = []

    for promotion in promotions:
        name = ""
        if not promotion.user.first_name and not promotion.user.last_name:
            name = promotion.user.cv.english_full_name
        else:
            name = f"{promotion.user.first_name} {promotion.user.last_name}"

        data.append({
            "id": promotion.id,
            "user_id": promotion.user_id,
            "name": name,
            "status": promotion.status,
            "start_date": promotion.start_date,
            "end_date": promotion.end_date,
            "passport_number": promotion.user.cv.passport_number
        }
    )   
        
    return data

@promotion_router.post("/create")
async def create_promotion(
    data: PromotionCreate,
    background_tasks: BackgroundTasks,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user: UserTokenSchema | None = context_actor_user_data.get()
    company = db.query(CompanyInfoModel).filter(CompanyInfoModel.user_id == user.id).first()
    try:
        subscription = db.query(PromotionSubscriptionModel).filter(PromotionSubscriptionModel.user_id == user.id,
                                                                    PromotionSubscriptionModel.status == "active").first()

        if not subscription:
            return Response(status_code=400, content=json.dumps({"message": "You need to buy a promotion package first"}),
                             media_type="application/json")

        if len(data.user_ids) > subscription.current_profile_count:
            return Response(status_code=400, content=json.dumps({"message": "You have exceeded the profile count limit"}),
                             media_type="application/json")

        employees = db.query(EmployeeModel).filter(EmployeeModel.user_id.in_(data.user_ids),
                                                    EmployeeModel.status == "complete").all()

        if not employees:
            return Response(status_code=400, content=json.dumps({"message": "No employees found"}), media_type="application/json")

        _users = db.query(UserModel).filter(UserModel.role != "employee", UserModel.id != user.id).all()

        for employee in employees:
            promotion = PromotionModel(
                user_id=employee.user_id,
                promoted_by_id=user.id,
                status="active",
                start_date=subscription.start_date,
                end_date=subscription.end_date
            )
            db.add(promotion)
                
        subscription.current_profile_count -= len(data.user_ids)

        db.add(subscription)
        
        db.commit()

    
        for _user in _users:
            email = _user.email or _user.company.alternative_email
            title = "New Promotion"
            description = f"A new Cv has been promoted, Hurry up and reserve it."
            background_tasks.add_task(send_notification, db, _user.id, title, description, "promotion")
            background_tasks.add_task(func=send_email, email=email, title=title, description=description)

        company_name = company.company_name if company and company.company_name else "an employer"

        if user.role != "employee":
            for employee in employees:
                email = employee.employee.cv.email or employee.employee.email
                title = "Promotion"
                description = f"Your CV has been promoted by {company_name}"
                background_tasks.add_task(send_notification, db, employee.user_id, title, description, "promotion")
                background_tasks.add_task(func=send_email, email=email, title=title, description=description)

        '''
        if user.role != "employee":
            for employee in employees:
                email = employee.employee.cv.email or employee.employee.email
                title = "Promotion"
                description = f"Your CV has been promoted by {company.company_name}"
                background_tasks.add_task(send_notification, db, employee.user_id, title, description, "promotion")
                background_tasks.add_task(func=send_email, email=email, title=title, description=description)
        '''
        return {"message": "Promotion created successfully"}

    except Exception as e:
        print(e)

        db.rollback()

        return Response(status_code=400, content=json.dumps({"message": "Failed to create promotion"}), media_type="application/json")


'''
ROLE_DISPLAY_MAP = {
    "recruitment": "RECRUITMENT FIRMS",
    "agent": "FOREIGN EMPLOYMENT AGENCIES",
    "sponsor": "EMPLOYER",
    "employee": "EMPLOYEE"
}

CATEGORY_DISPLAY_MAP = {
    "promotion": "Promote Profile",
    "reservation": "Reserve Profile",
    "transfer": "Transfer Profile",
    "job_application": "Post Jobs",
    "employee_process": "Accept Employeer Request"
}

# Sort categories by this custom order
CATEGORY_SORT_ORDER = ["promotion", "reservation", "transfer",  "job_application", "employee_process",]
CATEGORY_PRIORITY = {cat: idx for idx, cat in enumerate(CATEGORY_SORT_ORDER)}

@promotion_router.get("/admin/packages")
async def get_all_promotion_packages_admin(
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    promotions = db.query(PromotionPackagesModel).all()
    promotion_data = []

    for promotion in promotions:
        clean_role = promotion.role.value.strip().lower() if promotion.role else ""
        clean_category = promotion.category.value.strip().lower().replace(" ", "_") if promotion.category else ""

        promotion_data.append(
            {
                "id": promotion.id,
                "category": CATEGORY_DISPLAY_MAP.get(clean_category, clean_category.replace("_", " ").capitalize()),
                "raw_category": clean_category,  # used only for sorting
                "role": ROLE_DISPLAY_MAP.get(clean_role, clean_role.upper()),
                "duration": promotion.duration,
                "profile_count": promotion.profile_count,
                "price": promotion.price,
            }
        )

    # Sort based on custom category order
    promotion_data.sort(
        key=lambda item: CATEGORY_PRIORITY.get(item["raw_category"], len(CATEGORY_SORT_ORDER))
    )

    # Remove raw_category before returning
    for item in promotion_data:
        item.pop("raw_category")

    return {"data": promotion_data}

'''
import re
ROLE_DISPLAY_MAP = {
    "recruitment": "RECRUITMENT FIRMS",
    "agent": "FOREIGN EMPLOYMENT AGENCIES",
    "sponsor": "EMPLOYER",
    "employee": "EMPLOYEE"
}

CATEGORY_DISPLAY_MAP = {
    "promotion": "Promote Profile",
    "reservation": "Reserve Profile",
    "transfer": "Transfer Profile",
    "job_application": "Post Jobs",
    "employee_process": "Assigning Recruitment Firms to Import Workers"
}

# Sort categories by this custom order
CATEGORY_SORT_ORDER = ["promotion", "reservation", "transfer",  "job_application", "employee_process",]
CATEGORY_PRIORITY = {cat: idx for idx, cat in enumerate(CATEGORY_SORT_ORDER)}


DURATION_SORT_ORDER = {
    "1 Month": 2,
    "3 Months": 1,
    "6 Months": 0
}


@promotion_router.get("/admin/packages")
async def get_all_promotion_packages_admin(
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    promotions = db.query(PromotionPackagesModel).all()

    # Preprocess and normalize data
    promotion_data = []
    for promotion in promotions:
        clean_role = promotion.role.value.strip().lower() if promotion.role else ""
        clean_category = promotion.category.value.strip().lower().replace(" ", "_") if promotion.category else ""

        # Safely extract and normalize duration from Enum
        duration = promotion.duration.value if promotion.duration else None
        if duration:
            # Make sure "month"/"months" starts with capital M
            duration = re.sub(r"\b(months?)\b", lambda m: m.group(1).capitalize(), duration.lower())

        promotion_data.append({
            "id": promotion.id,
            "category": CATEGORY_DISPLAY_MAP.get(clean_category, clean_category.replace("_", " ").capitalize()),
            "raw_category": clean_category,
            "role": ROLE_DISPLAY_MAP.get(clean_role, clean_role.upper()),
            "raw_role": clean_role,
            "duration": duration,
            "profile_count": promotion.profile_count,
            "price": promotion.price,
        })

    # Organize data
    final_result = []

    for category_key in CATEGORY_SORT_ORDER:
        category_items = [item for item in promotion_data if item["raw_category"] == category_key]

        if not category_items:
            continue

        # Get unique roles in this category
        roles_in_category = sorted(set(item["raw_role"] for item in category_items))

        for role_key in roles_in_category:
            role_items = [item for item in category_items if item["raw_role"] == role_key]

            # Sort by duration using custom order
            role_items.sort(
                key=lambda x: DURATION_SORT_ORDER.get(x["duration"], 99)  # unknown durations go last
            )

            for item in role_items:
                clean_item = item.copy()
                clean_item.pop("raw_category", None)
                clean_item.pop("raw_role", None)
                final_result.append(clean_item)

    return {"data": final_result}
 
'''
@promotion_router.post("/admin/packages")
async def create_promotion_package(
    data: PromotionPackageCreateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    if user.role != "admin":
        return Response(status_code=403, content=json.dumps({"message": "You are not authorized to view this page"}), media_type="application/json")

    try:
        promotion = PromotionPackagesModel(
            category=data.category.name,
            role=data.role.name,
            duration=data.duration.name,
            profile_count=data.profile_count,
            price=data.price
        )

        db.add(promotion)
        db.commit()
        return {"message": "Promotion package created successfully"}

    except Exception as e:
        print(e)
        db.rollback()
        return Response(status_code=400, content=json.dumps({"message": "Failed to create promotion package"}), media_type="application/json")
'''


import json
import traceback

@promotion_router.patch("/admin/packages")
async def update_promotion_package(
    data: PromotionPackageUpdateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db: Session = get_db_session()
    user = context_actor_user_data.get()

    # DEBUG: print incoming request data
    print("Incoming update data:", data.dict())

    try:
        promotion = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.id == data.id).first()

        if not promotion:
            print(f"Promotion package with ID {data.id} not found.")
            return Response(
                status_code=404,
                content=json.dumps({"message": "Promotion package not found"}),
                media_type="application/json"
            )

        # DEBUG: Print current values before update
        print("Current promotion values:", {
            "category": promotion.category,
            "role": promotion.role,
            "duration": promotion.duration,
            "profile_count": promotion.profile_count,
            "price": promotion.price
        })

        # Update fields if provided
        if data.category:
            promotion.category = data.category.name
        if data.role:
            promotion.role = data.role.name
        if data.duration:
            promotion.duration = data.duration.name
        if data.profile_count is not None:
            promotion.profile_count = data.profile_count
        if data.price is not None:
            promotion.price = data.price

        # DEBUG: Print updated values before commit
        print("Updated promotion values:", {
            "category": promotion.category,
            "role": promotion.role,
            "duration": promotion.duration,
            "profile_count": promotion.profile_count,
            "price": promotion.price
        })

        db.add(promotion)
        db.commit()

        return {"message": "Promotion package updated successfully"}

    except Exception as e:
        db.rollback()
        # Print stack trace for full debug info
        traceback.print_exc()
        return Response(
            status_code=400,
            content=json.dumps({
                "message": "Failed to update promotion package",
                "error": str(e)
            }),
            media_type="application/json"
        )

@promotion_router.delete("/admin/packages")
async def delete_promotion_package(
    data: PromotionPackageUpdateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    if user.role != "admin":
        return Response(status_code=403, content=json.dumps({"message": "You are not authorized to view this page"}), media_type="application/json")

    promotion = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.id == data.id).first()

    if not promotion:
        return Response(status_code=404, content=json.dumps({"message": "Promotion package not found"}), media_type="application/json")

    try:
        db.delete(promotion)
        db.commit()
        return {"message": "Promotion package deleted successfully"}
    except Exception as e:
        print(e)
        db.rollback()
        return Response(status_code=400, content=json.dumps({"message": "Failed to delete promotion package"}), media_type="application/json")

@promotion_router.delete("/remove")
async def remove_promotion(data: BuyPromotionPackage, _=Depends(authentication_context), __=Depends(build_request_context)):
    db = get_db_session()
    user = context_actor_user_data.get()

    promotion = db.query(PromotionModel).filter(PromotionModel.id == data.id, PromotionModel.promoted_by_id == user.id).first()

    if not promotion:
        return Response(status_code=404, content=json.dumps({"message": "Promotion not found"}), media_type="application/json")

    subscription = db.query(PromotionSubscriptionModel).filter(PromotionSubscriptionModel.user_id == user.id, PromotionSubscriptionModel.status == "active").first()

    if promotion.start_date == subscription.start_date and promotion.end_date == subscription.end_date:
        subscription.current_profile_count += 1

        db.add(subscription)

    try:
        db.delete(promotion)
        db.commit()
        return {"message": "Promotion removed successfully"}
    except Exception as e:
        print(e)
        db.rollback()
        return Response(status_code=400, content=json.dumps({"message": "Failed to remove promotion"}), media_type="application/json")


@promotion_router.get("/employee")
async def get_employee_promotion(
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    employees = db.query(EmployeeModel).filter(EmployeeModel.manager_id == user.id, EmployeeModel.status == "complete").all()

    if not employees:
        return Response(status_code=404, content=json.dumps({"message": "No employees found"}), media_type="application/json")
    
    # Check if the employee has a promotion active, if yes remove them from the employee list
    active_promotions = db.query(PromotionModel).filter(PromotionModel.status == "active", PromotionModel.promoted_by_id == user.id).all()

    active_promotion_user_ids = {promotion.user_id for promotion in active_promotions}

    employees = [employee for employee in employees if employee.user_id not in active_promotion_user_ids]

    employee_data = []

    for employee in employees:
        cv = db.query(CVModel).filter(CVModel.user_id == employee.user_id).first()
        if not cv:
            continue
        name = ""

        if not employee.employee.first_name and not employee.employee.last_name:
            name = cv.english_full_name
        else:
            name = f"{employee.employee.first_name} {employee.employee.last_name}"

        employee_data.append({
            "id": employee.id,
            "name": name,
            "status": employee.status,
            "user_id": employee.user_id,
            "passport_number": cv.passport_number
        })

    return {"data": employee_data}


@promotion_router.post("/admin/packages")
async def create_promotion_package(
    data: PromotionPackageCreateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    db = get_db_session()
    user = context_actor_user_data.get()

    if user.role != "admin":
        return Response(status_code=403, content=json.dumps({"message": "You are not authorized to view this page"}), media_type="application/json")

    try:
        promotion = PromotionPackagesModel(
            category=data.category.name,
            role=data.role.name,
            duration=data.duration.name,
            profile_count=data.profile_count,
            price=data.price
        )

        db.add(promotion)
        db.commit()
        return {"message": "Promotion package created successfully"}

    except Exception as e:
        print(e)
        db.rollback()
        return Response(status_code=400, content=json.dumps({"message": "Failed to create promotion package"}), media_type="application/json")