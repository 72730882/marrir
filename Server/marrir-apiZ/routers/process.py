from typing import Any, Optional, Annotated
import uuid

from fastapi import APIRouter, Depends, File, Form, Response, Header, UploadFile
from fastapi.security import HTTPBearer
from starlette.requests import Request

from core.auth import rbac_access_checker, RBACResource, RBACAccessType
from core.context_vars import context_set_response_code_message
from models.db import build_request_context, get_db_session, authentication_context
from models.processmodel import ProcessModel
from repositories.process import ProcessRepository
from routers import version_prefix
from schemas.base import GenericSingleResponse, GenericMultipleResponse
from schemas.enumschema import ProcessStatusSchema
from schemas.processschema import (
    EmployeeProcessSchema,
    ProcessProgressSchema,
    ProcessUpsertSchema,
    ProcessFilterSchema,
    ProcessReadSchema,
)

process_router_prefix = version_prefix + "process"

process_router = APIRouter(prefix=process_router_prefix)


@process_router.post(
    "/",
    response_model=GenericSingleResponse[ProcessReadSchema],
    status_code=200,
)
async def create_update_process(
    *,
    user_id: uuid.UUID = Form(...),
    file_status: Optional[ProcessStatusSchema] = Form(None),
    file_type: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None),
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
):
    """
    create or update a process
    """
    db = get_db_session()
    process_repo = ProcessRepository(entity=ProcessModel)
    process_created = process_repo.upsert(
        db, user_id=user_id, file_type=file_type, file=file, file_status=file_status
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": process_created,
    }


@process_router.post(
    "/progress",
    response_model=GenericSingleResponse[ProcessProgressSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.process, rbac_access_type=RBACAccessType.read
)
async def get_process_progress(
    *,
    filters: Optional[ProcessFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve process completion stat.
    """
    db = get_db_session()
    process_repo = ProcessRepository(entity=ProcessModel)
    process_read = process_repo.progress(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": process_read,
    }


@process_router.post(
    "/employees",
    response_model=GenericMultipleResponse[EmployeeProcessSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.process, rbac_access_type=RBACAccessType.read_multiple
)
async def view_employees_process_status(
    *,
    filters: Optional[ProcessFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve my employee's process status.
    """
    db = get_db_session()
    process_repo = ProcessRepository(entity=ProcessModel)
    processs_read = process_repo.get_my_employees_processes(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": processs_read,
        "count": len(processs_read)
    }


@process_router.post(
    "/single",
    response_model=GenericSingleResponse[ProcessReadSchema],
    status_code=201,
)
async def read_process(
    *,
    filters: Optional[ProcessFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
):
    """
    read single process
    """
    db = get_db_session()
    process_repo = ProcessRepository(entity=ProcessModel)
    process_read = process_repo.get(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": process_read,
    }


@process_router.delete(
    "/",
    response_model=GenericSingleResponse[ProcessReadSchema],
    status_code=200,
)
async def delete_process(
    *,
    filters: Optional[ProcessFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
):
    """
    delete user process
    """
    db = get_db_session()
    process_repo = ProcessRepository(entity=ProcessModel)
    process_deleted = process_repo.delete(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": process_deleted,
    }
    
    
    
@process_router.post(
    "/generate-pdf",
    response_model=None,
    status_code=200,
)
async def generate_process_report(
    *,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    filters: Optional[ProcessFilterSchema] = None,
    request: Request,
    response: Response,
) -> Any:
    """
    generate process report.
    """
    db = get_db_session()
    process_repo = ProcessRepository(entity=ProcessModel)
    process_created = process_repo.export_to_pdf_process(
        db, request=request, title="Employee Process Report", filters=filters
    )

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": process_created,
    }


