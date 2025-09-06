from datetime import datetime, timezone
import json
from typing import Any, List, Optional
import uuid
from fastapi import APIRouter, Depends, Query, Response, UploadFile, BackgroundTasks
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db_session
from models.invoicemodel import InvoiceModel
from models.jobapplicationmodel import JobApplicationModel
from models.jobmodel import JobModel
from models.promotionmodel import PromotionPackagesModel
from repositories.job import JobRepository
from repositories.jobapplication import JobApplicationRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message, context_actor_user_data
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.jobschema import (
    ApplicationStatusUpdateSchema,
    ApplyJobMultipleBaseSchema,
    ApplyJobReadSchema,
    ApplyJobSingleBaseSchema,
    ApplyJobSingleReadSchema,
    JobApplicationDeleteSchema,
    JobApplicationPaymentInfoSchema,
    JobBaseSchema,
    JobCreateSchema,
    JobReadSchema,
    JobUpdateSchema,
    JobsFilterSchema,
    JobsSearchSchema,
)
import logging
from telr_payment.api import Telr

from schemas.transferschema import TransferRequestPaymentCallback
from utils.send_email import send_email
from models.notificationmodel import Notifications
from core.security import settings
logger = logging.getLogger(__name__)

job_router_prefix = version_prefix + "job"

job_router = APIRouter(prefix=job_router_prefix)

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


@job_router.post(
    "/", response_model=GenericSingleResponse[JobReadSchema], status_code=201
)
@rbac_access_checker(resource=RBACResource.job, rbac_access_type=RBACAccessType.create)
async def create_job_post(
    *,
    job_in: JobCreateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    create a new job post
    """
    db = get_db_session()
    job_repo = JobRepository(entity=JobModel)
    new_job = job_repo.create(db, obj_in=job_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": new_job,
    }


@job_router.post("/bulk", response_model=None, status_code=201)
async def bulk_create_job(
    *,
    file: UploadFile,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    create many new jobs.
    """
    db = get_db_session()
    job_repo = JobRepository(entity=JobModel)
    job_created = job_repo.bulk_upload(db, file=file)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {}


@job_router.post(
    "/paginated", response_model=GenericMultipleResponse[JobReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.job, rbac_access_type=RBACAccessType.read_multiple
)
async def read_job_posts(
    *,
    filters: Optional[JobsFilterSchema] = None,
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
    Retrieve paginated job posts.
    """
    db = get_db_session()
    job_repo = JobRepository(entity=JobModel)
    jobs_read = job_repo.get_some(
        db,
        skip=skip,
        limit=limit,
        search=search,
        search_schema=JobsSearchSchema,
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
        "data": jobs_read,
        "count": res_data.count,
    }


@job_router.post(
    "/single", response_model=GenericSingleResponse[JobReadSchema], status_code=200
)
@rbac_access_checker(resource=RBACResource.job, rbac_access_type=RBACAccessType.read)
async def read_job_post(
    *,
    filters: Optional[JobsFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve single job post.
    """
    db = get_db_session()
    job_repo = JobRepository(entity=JobModel)
    job_read = job_repo.get(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": job_read,
    }


@job_router.patch(
    "/", response_model=GenericSingleResponse[JobReadSchema], status_code=200
)
@rbac_access_checker(resource=RBACResource.job, rbac_access_type=RBACAccessType.update)
async def update_job_post(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    job_update: JobUpdateSchema,
    request: Request,
    response: Response
) -> Any:
    """
    Update a job post
    """
    db = get_db_session()
    job_repo = JobRepository(entity=JobModel)
    job_updated = job_repo.update(
        db, filter_obj_in=job_update.filter, obj_in=job_update.update
    )

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": job_updated,
    }


@job_router.delete(
    "/close", response_model=GenericSingleResponse[JobReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.job, rbac_access_type=RBACAccessType.soft_delete
)
async def close_job_post(
    *,
    filters: Optional[JobsFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    close a job post
    """
    db = get_db_session()
    job_repo = JobRepository(entity=JobModel)
    job_deleted = job_repo.soft_delete(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": job_deleted,
    }


@job_router.delete(
    "/", response_model=GenericSingleResponse[JobReadSchema], status_code=200
)
@rbac_access_checker(resource=RBACResource.job, rbac_access_type=RBACAccessType.delete)
async def remove_job_post(
    *,
    filters: Optional[JobsFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    delete a job post
    """
    db = get_db_session()
    job_repo = JobRepository(entity=JobModel)
    job_deleted = job_repo.delete(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": job_deleted,
    }


@job_router.post(
    "/apply",
    response_model=GenericMultipleResponse[ApplyJobReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.job_application, rbac_access_type=RBACAccessType.create
)
async def apply_for_job(
    *,
    job_in: ApplyJobMultipleBaseSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    apply for a job post
    """
    db = get_db_session()
    job_application_repo = JobApplicationRepository(entity=JobApplicationModel)
    new_job_application = job_application_repo.apply(db, obj_in=job_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": new_job_application,
    }


@job_router.delete(
    "/apply/remove",
    response_model=GenericSingleResponse[ApplyJobSingleReadSchema],
    status_code=200,
)
async def remove_job_application(
    *,
    filters: Optional[JobApplicationDeleteSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    remove application for a job post
    """
    db = get_db_session()
    job_application_repo = JobApplicationRepository(entity=JobApplicationModel)
    job_application_deleted = job_application_repo.delete(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        # "status_code": 200,
        # "message": "message",
        # "error": False,
        # "data": {
        #     "user_email": "",
        #     "job_id": 1
        # },
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": job_application_deleted,
    }

@job_router.get("/my-applications/{job_id}", response_model=list[ApplyJobReadSchema])
async def get_my_applications(job_id: int,_=Depends(authentication_context),__=Depends(build_request_context)):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()

        if user.role != "recruitment" and user.role != "sponsor":
            return Response(status_code=403, content=json.dumps({"message": "Unauthorized"}), media_type="application/json")
        
        jobs = db.query(JobModel).filter(JobModel.id == job_id, JobModel.posted_by == user.id).first()

        if not jobs:
            return Response(status_code=404, content=json.dumps({"message": "Job not found"}), media_type="application/json")
        
        return jobs.job_applications

    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": str(e)}), media_type="application/json")


def create_invoice(db, ref: str, amount: float, user_id: uuid.UUID, job_id: str) -> InvoiceModel:
    invoice = InvoiceModel(
        stripe_session_id=ref,
        status="pending",
        amount=amount,
        created_at=datetime.now(timezone.utc),
        type="job_application",
        buyer_id=user_id,
        object_id=job_id,
    )
    db.add(invoice)
    return invoice


def update_invoice(invoice: InvoiceModel, ref: str) -> None:
    invoice.stripe_session_id = ref

@job_router.patch("/my-applications/{job_id}/status")
async def update_job_application_status(data: ApplicationStatusUpdateSchema, job_id: int, background_tasks: BackgroundTasks, _=Depends(authentication_context),__=Depends(build_request_context)):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()

        if user.role != "recruitment" and user.role != "sponsor":
            return Response(status_code=403, content=json.dumps({"message": "Unauthorized"}), media_type="application/json")

        job = db.query(JobModel).filter(JobModel.id == job_id).first()

        if not job:
            return Response(status_code=404, content=json.dumps({"message": "Job not found"}), media_type="application/json")

        jobs_applications: List[JobApplicationModel] = db.query(JobApplicationModel).filter(JobApplicationModel.job_id == job_id, JobApplicationModel.id.in_(data.job_application_ids), JobApplicationModel.status == "pending").all()
        
        if not jobs_applications:
            return Response(status_code=404, content=json.dumps({"message": "Job applications not found"}), media_type="application/json")

        for job_application in jobs_applications:
            if job_application.job.posted_by != user.id:
                return Response(status_code=403, content=json.dumps({"message": "Unauthorized"}), media_type="application/json")

        if data.status == "declined":
            for job_application in jobs_applications:
                job_application.status = "declined"
                db.add(job_application)

            db.commit()

            title = "Job Application Declined"

            description = f"{job.job_poster.first_name} {job.job_poster.last_name} has declined the job application for {job.name}"

            background_tasks.add_task(send_notification, db, job_application.user_id, title, description, "job_application")

            email = job_application.user.email or job_application.user.cv.email

            background_tasks.add_task(send_email, email=email, title=title, description=description)

            return {"message": "Job applications status updated successfully"}

        if data.status == "accepted":
            package = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.role == user.role, PromotionPackagesModel.category == "job_application").first()

#            return_url = f"{settings.TELR_JOB_APPLICATION_RETURN_URL.replace("replace", user.role)}/{job_id}"
            return_url = f"{settings.TELR_JOB_APPLICATION_RETURN_URL.replace('replace', user.role)}/{job_id}"

            for job_application in jobs_applications:

                job_application = db.query(JobApplicationModel).filter(JobApplicationModel.user_id == job_application.user_id, JobApplicationModel.status == "accepted").first()

                if job_application:
                    return Response(status_code=400, content=json.dumps({"message": f"{job_application.user.first_name} {job_application.user.last_name} has already been accepted for other job"}), media_type="application/json")

            order_response = telr.order(
                order_id=f"ORDER{uuid.uuid4().hex[:8]}",
                amount=package.price * len(jobs_applications),
                currency="AED",
                return_url=return_url,
                return_decl=return_url,
                return_can=return_url,
                description=f"Job Application"
            )

            ref = order_response.get("order", {}).get("ref")

            if not ref:
                return Response(status_code=400, content=json.dumps({"message": "Failed to process payment"}), media_type="application/json")

            ids = ",".join([str(tr.id) for tr in jobs_applications])

            invoice = db.query(InvoiceModel).filter(
                InvoiceModel.buyer_id == user.id,
                InvoiceModel.status == "pending",
                InvoiceModel.type == "job_application"
            ).first()

            if invoice:
                update_invoice(invoice, ref)
            else:
                invoice = create_invoice(db, ref, len(jobs_applications) * 10, user.id, ids)
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

    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": str(e)}), media_type="application/json")


@job_router.post("/my-applications/status/callback")
async def update_job_application_status_callback(data: TransferRequestPaymentCallback, background_tasks: BackgroundTasks, _=Depends(authentication_context),__=Depends(build_request_context)):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()

        if user.role != "recruitment" and user.role != "sponsor":
            return Response(status_code=403, content=json.dumps({"message": "Unauthorized"}), media_type="application/json")

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
            InvoiceModel.type == "job_application"
        ).first()

        if not invoice:
            return Response(status_code=404, content=json.dumps({"message": "Invoice not found"}), media_type="application/json")
        
        job_applications = db.query(JobApplicationModel).filter(
            JobApplicationModel.id.in_(map(int, invoice.object_id.split(','))),
            JobApplicationModel.status == "pending"
        ).all()

        if not job_applications:
            return Response(status_code=404, content=json.dumps({"message": "Job applications not found"}), media_type="application/json")

        invoice.status = "paid"
        invoice.card = card_type
        invoice.description = description
        db.add(invoice)

        for job_application in job_applications:
            job_application.status = "accepted"
            db.add(job_application)

        db.commit()

        title = "Job Application Accepted"

        job = db.query(JobModel).filter(JobModel.id == job_applications[0].job_id).first()

        description = f"{job.job_poster.first_name} {job.job_poster.last_name} has accepted the job application for {job.name}"

        for job_application in job_applications:
            background_tasks.add_task(send_notification, db, job_application.user_id, title, description, "job_application")

            email = job_application.user.email or job_application.user.cv.email

            background_tasks.add_task(send_email, email=email, title=title, description=description)

        return {"message": "Job applications status updated successfully"}

    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": str(e)}), media_type="application/json")


@job_router.post("/my-applications/payment/info")
async def get_job_application_payment_info(data: JobApplicationPaymentInfoSchema, _=Depends(authentication_context),__=Depends(build_request_context)):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()

        jobs_applications: List[JobApplicationModel] = db.query(JobApplicationModel).filter(JobApplicationModel.job_id == data.job_id, JobApplicationModel.id.in_(data.job_application_ids), JobApplicationModel.status == "pending").all()
        
        if not jobs_applications:
            return Response(status_code=404, content=json.dumps({"message": "Job applications not found"}), media_type="application/json")

        for job_application in jobs_applications:
            if job_application.job.posted_by != user.id:
                return Response(status_code=403, content=json.dumps({"message": "Unauthorized"}), media_type="application/json")

        package = db.query(PromotionPackagesModel).filter(PromotionPackagesModel.role == user.role, PromotionPackagesModel.category == "job_application").first()

        return {
            "price": package.price,
            "total_amount": package.price * len(jobs_applications),
            "profile": len(jobs_applications)
        }

    except Exception as e:
        print(e)
        return Response(status_code=400, content=json.dumps({"message": str(e)}), media_type="application/json")