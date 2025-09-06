from datetime import datetime
from http.client import HTTPException
import json
import logging
from io import BytesIO
from typing import Any, Optional
import uuid
from fastapi import APIRouter, Depends, File, Form, Query, Response, UploadFile
from fastapi.responses import StreamingResponse
from fastapi.templating import Jinja2Templates
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.additionallanguagemodel import AdditionalLanguageModel
from models.db import authentication_context, build_request_context, get_db_session
from models.cvmodel import CVModel
from models.referencemodel import ReferenceModel
from models.usermodel import UserModel 
from models.workexperiencemodel import WorkExperienceModel
from repositories.cv import CVRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.cvschema import (
    AdditionalLanguageCreateSchema,
    AdditionalLanguageData,
    AdditionalLanguageReadSchema,
    CVFilterSchema,
    CVProgressSchema,
    CVReadSchema,
    CVUpsertSchema,
)
from utils.generate_qr import my_qr_code
from core.security import settings

cv_router_prefix = version_prefix + "cv"

cv_router = APIRouter(prefix=cv_router_prefix)


@cv_router.post(
    "/", response_model=GenericSingleResponse[CVReadSchema], status_code=200
)
@rbac_access_checker(resource=RBACResource.cv, rbac_access_type=RBACAccessType.create)
async def create_update_cv(
    *,
    cv_data_json: str = Form(...),
    head_photo: Optional[UploadFile] = None,
    full_body_photo: Optional[UploadFile] = None,
    intro_video: Optional[UploadFile] = None,    
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    create a new cv
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)
    new_cv = cv_repo.upsert(
        db,
        cv_data_json=cv_data_json,
        head_photo=head_photo,
        full_body_photo=full_body_photo,
        intro_video=intro_video,
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": new_cv,
    }




from fastapi import UploadFile, Request, Response, Depends
from io import BytesIO
from typing import List, Any
from sqlalchemy.orm import Session

@cv_router.post(
    "/bulk", response_model=GenericSingleResponse[List[CVReadSchema]], status_code=201
)
@rbac_access_checker(resource=RBACResource.cv, rbac_access_type=RBACAccessType.create)
async def bulk_create_cv(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    file: UploadFile,
    request: Request,
    response: Response,
) -> Any:
    """
    Create many new CVs via Excel upload.
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)

    contents = await file.read()
    excel_io = BytesIO(contents)

    created_cvs = cv_repo.bulk_upload(db, file=excel_io)

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": created_cvs,
    }


@cv_router.post(
    "/progress", response_model=GenericSingleResponse[CVProgressSchema], status_code=200
)
@rbac_access_checker(resource=RBACResource.cv, rbac_access_type=RBACAccessType.read)
async def get_cv_progress(
    *,
    filters: Optional[CVFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve cv completion stat.
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)
    cv_read = cv_repo.progress(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": cv_read,
    }


@cv_router.post(
    "/single", response_model=GenericSingleResponse[CVReadSchema], status_code=200
)
@rbac_access_checker(resource=RBACResource.cv, rbac_access_type=RBACAccessType.read)
async def read_cv_post(
    *,
    filters: Optional[CVFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve single cv.
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)
    cv_read = cv_repo.get(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": cv_read,
    }


@cv_router.post(
    "/languages",
    response_model=GenericSingleResponse[AdditionalLanguageData],
    status_code=200,
)
async def add_cv_additional_languages(
    *,
    obj_in: AdditionalLanguageCreateSchema = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Add additional languages for cv.
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)
    languages = cv_repo.add_language(db, obj_in=obj_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": languages,
    }


@cv_router.post(
    "/languages/list",
    response_model=GenericMultipleResponse[AdditionalLanguageReadSchema],
    status_code=200,
)
async def get_cv_additional_languages(
    *,
    obj_in: CVFilterSchema = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Get additional languages for cv.
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)
    languages = cv_repo.get_additional_languages(db, filters=obj_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": languages,
    }


@cv_router.delete(
    "/languages",
    response_model=GenericSingleResponse[AdditionalLanguageData],
    status_code=200,
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.delete)
async def delete_additional_language(
    *,
    filters: Optional[AdditionalLanguageReadSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Delete additional language.
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)
    language_deleted = cv_repo.delete_language(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": language_deleted,
    }


@cv_router.post(
    "/passport",
    response_model=GenericSingleResponse[CVReadSchema],
    status_code=200,
)
async def upload_passport(
    *,
    user_id: Optional[uuid.UUID] = None,
    file: UploadFile,
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    populate cv from passport.
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)
    cv_created = cv_repo.upload_passport(db, user_id=user_id, file=file)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": cv_created,
    }


from fastapi.security import HTTPBearer




'''
@cv_router.post(
    "/generate-report",
    response_model=None,
    status_code=200,
)
async def generate_cv_report(
    *,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    filters: Optional[CVFilterSchema] = None,
    request: Request,
    response: Response,
) -> Any:
    """
    generate cv report.
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)
    cv_created = cv_repo.export_to_pdf(
        db, request=request, title="Curriculum Vitae", filters=filters
    )

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": cv_created,
    }
'''



@cv_router.post(
    "/generate-report",
    response_model=None,
    status_code=200,
)
async def generate_cv_report(
    *,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    filters: Optional[CVFilterSchema] = None,
    request: Request,
    response: Response,
) -> Any:
    """
    generate cv report.
    """
    logger = logging.getLogger(__name__)
    logger.info("Received CV report generation request")
    logger.debug(f"Request filters: {filters}")

    try:
        db = get_db_session()
        cv_repo = CVRepository(entity=CVModel)
        
        logger.info("Starting PDF generation process")
        cv_created = cv_repo.export_to_pdf(
            db, request=request, title="Curriculum Vitae", filters=filters
        )

        res_data = context_set_response_code_message.get()
        response.status_code = res_data.status_code
        
        logger.info(f"PDF generation completed with status code: {res_data.status_code}")
        logger.debug(f"Response message: {res_data.message}")
        
        if res_data.error:
            logger.warning(f"PDF generation completed with error: {res_data.message}")
        else:
            logger.info("PDF generated successfully")

        return {
            "status_code": res_data.status_code,
            "message": res_data.message,
            "error": res_data.error,
            "data": cv_created,
        }
        
    except Exception as e:
        logger.error(f"Error generating CV report: {str(e)}", exc_info=True)
        raise HTTPException(
           
            detail="An error occurred while generating the CV report"
        )


@cv_router.post(
    "/generate-report",
    response_model=None,
    status_code=200,
)
async def generate_cv_report(
    *,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    filters: Optional[CVFilterSchema] = None,
    request: Request,
    response: Response,
) -> Any:
    """
    generate cv report.
    """
    logger = logging.getLogger(__name__)
    logger.info("Received CV report generation request")
    logger.debug(f"Request filters: {filters}")

    try:
        db = get_db_session()
        cv_repo = CVRepository(entity=CVModel)
        
        logger.info("Starting PDF generation process")
        cv_created = cv_repo.export_to_pdf(
            db, request=request, title="Curriculum Vitae", filters=filters
        )

        res_data = context_set_response_code_message.get()
        response.status_code = res_data.status_code
        
        logger.info(f"PDF generation completed with status code: {res_data.status_code}")
        logger.debug(f"Response message: {res_data.message}")
        
        if res_data.error:
            logger.warning(f"PDF generation completed with error: {res_data.message}")
        else:
            logger.info("PDF generated successfully")

        return {
            "status_code": res_data.status_code,
            "message": res_data.message,
            "error": res_data.error,
            "data": cv_created,
        }
        
    except Exception as e:
        logger.error(f"Error generating CV report: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while generating the CV report"
        )
        
@cv_router.post(
    "/generate-saudi",
    response_model=None,
    status_code=200,
)
async def generate_saudi_report(
    *,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    filters: Optional[CVFilterSchema] = None,
    request: Request,
    response: Response,
) -> Any:
    """
    generate saudi report.
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)
    cv_created = cv_repo.export_to_pdf_saudi(
        db, request=request, title="Saudi Embassy File", filters=filters
    )

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": cv_created,
    }


@cv_router.delete(
    "/", response_model=GenericSingleResponse[CVReadSchema], status_code=200
)
@rbac_access_checker(resource=RBACResource.cv, rbac_access_type=RBACAccessType.delete)
async def delete_cv(
    *,
    filters: Optional[CVFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    delete a cv post
    """
    db = get_db_session()
    cv_repo = CVRepository(entity=CVModel)
    cv_deleted = cv_repo.delete(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": cv_deleted,
    }


@cv_router.get("/rating")
async def get_cv_rating(
    *,
    employee_id: uuid.UUID,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
):
    db = get_db_session()

    cv = db.query(CVModel).filter(CVModel.user_id == employee_id).first()

    if not cv:
        return Response(status_code=404, content="CV not found")
    
    references = db.query(ReferenceModel).filter(ReferenceModel.cv_id == cv.id).all()

    rating = 0

    if references:
        rating += 1

    work_experiences = db.query(WorkExperienceModel).filter(WorkExperienceModel.cv_id == cv.id).all()

    if work_experiences:
        if len(work_experiences) >= 2:
            rating += 2
        elif len(work_experiences) == 1:
            rating += 1


    additional_languages = db.query(AdditionalLanguageModel).filter(AdditionalLanguageModel.cv_id == cv.id).all()

    if additional_languages:
        if len(additional_languages) > 2:
            rating += 1.5
        elif len(additional_languages) == 2:
            rating += 1
        else:
            rating += 0.5

    return {"rating": rating}


@cv_router.get("/public/{cv_id}", response_model=CVReadSchema)
async def get_cv_public(cv_id: int, __=Depends(build_request_context)):
    db = get_db_session()
    try:
        cv = db.query(CVModel).filter(CVModel.id == cv_id).first()
        if not cv:
            return Response(status_code=404, content="CV not found")
    
        return cv
    except Exception as e:
        print(e)
        return Response(status_code=400, content="Internal Server Error")


@cv_router.get("/download/{user_id}")
async def download_cv(request: Request, user_id: uuid.UUID, __=Depends(build_request_context)):
    try:
        db = get_db_session()
        templates = Jinja2Templates(directory="templates")
        user = db.query(UserModel).filter(UserModel.id == user_id).first()
        if not user:
            return Response(status_code=404, content=json.dumps({"error": "User not found"}), media_type="application/json")
        
        if user.role != "employee":
            return Response(status_code=400, content=json.dumps({"error": "The user you are trying to download the CV for is not an employee"}), media_type="application/json")

        if not user.cv:
            return Response(status_code=400, content=json.dumps({"error": "The user you are trying to download the CV for does not have a CV"}), media_type="application/json")

        owner_data = {}

        if user.employees:
            manager_id = user.employees[0].manager_id
            manager = db.query(UserModel).filter(UserModel.id == manager_id).first()
            if manager.role == "agent" or manager.role == "recruitment" or manager.role == "sponsor":
                owner_data = {
                    "company_name": manager.company.company_name,
                    "name": f"{manager.first_name} {manager.last_name}",
                    "phone_number": manager.phone_number,
                    "email": manager.email,
                    "location": manager.company.location
                }

        qr_code = my_qr_code(f"{settings.FRONTEND_PUBLIC_CV_URL}/{user.cv.id}")

        rate = 0

        additional_languages = []

        additional_languages.append({
            "language": "Amharic",
            "proficiency": user.cv.amharic
        })

        additional_languages.append({
            "language": "Arabic",
            "proficiency": user.cv.arabic
        })

        additional_languages.append({
            "language": "English",
            "proficiency": user.cv.english
        })

        if user.cv.references:
            rate += 1

        if user.cv.work_experiences:
            if len(user.cv.work_experiences) >= 2:
                rate += 2
            elif len(user.cv.work_experiences) == 1:
                rate += 1
        if user.cv.additional_languages:
            if len(user.cv.additional_languages) > 2:
                rate += 1.5
            elif len(user.cv.additional_languages) == 2:
                rate += 1
            else:
                rate += 0.5

        for lang in user.cv.additional_languages:
            additional_languages.append({
                "language": lang.language.capitalize().rstrip().lstrip(),
                "proficiency": lang.proficiency
            })

        additional_languages.sort(key=lambda x: x["language"], reverse=False)

        if user.cv.education and user.cv.education.highest_level in ["bsc", "msc", "phd"]:
            template = templates.get_template("cv.html")
        else:
            template = templates.get_template("cv_non_graduate.html")

        age = 0

        try:
            date_str = user.cv.date_of_birth.split('T')[0]
            age = datetime.now().year - datetime.strptime(date_str, "%Y-%m-%d").year
        except Exception as e:
            print(e)
        content = template.render(
                request=request,
                user=user.cv,
                img_base64=qr_code,
                passport_url=user.cv.passport_url,
                base_url=f"{settings.BASE_URL}/static",
                rate=rate,
                additional_languages=additional_languages,
                owner=owner_data,
                description=user.cv.summary,
                age=age
            )
        
        # return StreamingResponse(content=content, media_type="text/html")
        return {"data": content}
    except Exception as e:
        print(e)
        return Response(status_code=400, content="Internal Server Error")
