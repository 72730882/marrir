from typing import Any, Optional, Annotated

from fastapi import APIRouter, Depends, Response, Header, UploadFile
from fastapi.security import HTTPBearer
from pydantic import EmailStr
import requests
from starlette.requests import Request

from authlib.integrations.starlette_client import OAuth
from core.auth import rbac_access_checker, RBACResource, RBACAccessType
from core.context_vars import context_set_response_code_message
from core.security import Settings
from models.db import build_request_context, get_db_session, authentication_context
from models.occupationmodel import OccupationModel
from repositories.occupation import OccupationRepository
from routers import version_prefix
from schemas.base import GenericSingleResponse, GenericMultipleResponse
from schemas.occupationSchema import (
    OccupationCategoryCreateSchema,
    OccupationCategoryReadSchema,
    OccupationCategoryUpdateSchema,
    OccupationCreateSchema,
    OccupationFilterSchema,
    OccupationReadSchema,
    OccupationUpdateSchema,
)

occupation_router_prefix = version_prefix + "occupation"

occupation_router = APIRouter(prefix=occupation_router_prefix)

@occupation_router.post(
    "/",
    response_model=GenericSingleResponse[OccupationReadSchema],
    status_code=201,
)
async def create_occupation(
    *,
    occupation_in: OccupationCreateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    create a new occupation.
    """
    db = get_db_session()
    occupation_repo = OccupationRepository(entity=OccupationModel)
    occupation_created = occupation_repo.create(db, obj_in=occupation_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": occupation_created,
    }

@occupation_router.get(
    "/",
    response_model=GenericMultipleResponse[OccupationReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.occupation, rbac_access_type=RBACAccessType.read_multiple
)
async def read_occupations(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve occupations.
    """
    db = get_db_session()
    occupation_repo = OccupationRepository(entity=OccupationModel)
    occupations_read = occupation_repo.get_occupations(db)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": occupations_read
    }

@occupation_router.put(
    "/", response_model=GenericSingleResponse[OccupationReadSchema], status_code=200
)
# @rbac_access_checker(resource=RBACResource.occupations, rbac_access_type=RBACAccessType.update)
async def update_occupation(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    occupation_update: OccupationUpdateSchema,
    request: Request,
    response: Response,
) -> Any:
    """
    Update an occupation
    """

    db = get_db_session()
    occupation_repo = OccupationRepository(entity=OccupationModel)
    occupation_updated = occupation_repo.update(
        db, filter_obj_in=occupation_update.filter, obj_in=occupation_update.update
    )

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": occupation_updated,
    }


@occupation_router.delete(
    "/", response_model=GenericSingleResponse[OccupationReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.occupation, rbac_access_type=RBACAccessType.delete
)
async def delete_occupation(
    *,
    filters: Optional[OccupationFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Delete an occupation.
    """
    db = get_db_session()
    occupation_repo = OccupationRepository(entity=OccupationModel)
    occupation_deleted = occupation_repo.delete(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": occupation_deleted,
    }


@occupation_router.post(
    "/category",
    response_model=GenericSingleResponse[OccupationCategoryReadSchema],
    status_code=201,
)
async def create_occupation_category(
    *,
    occupation_in: OccupationCategoryCreateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    create a new occupation category.
    """
    db = get_db_session()
    occupation_repo = OccupationRepository(entity=OccupationModel)
    occupation_created = occupation_repo.create_category(db, obj_in=occupation_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": occupation_created,
    }

@occupation_router.get(
    "/category",
    response_model=GenericMultipleResponse[OccupationCategoryReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.occupation, rbac_access_type=RBACAccessType.read_multiple
)
async def read_occupation_categories(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve occupation categories.
    """
    db = get_db_session()
    occupation_repo = OccupationRepository(entity=OccupationModel)
    occupations_read = occupation_repo.get_categories(db)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": occupations_read,
        "count": res_data.count,
    }


@occupation_router.get(
    "/category/single",
    response_model=GenericSingleResponse[OccupationCategoryReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.occupation, rbac_access_type=RBACAccessType.read
)
async def read_occupation_category(
    *,
    category_id: int,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve occupation.
    """
    db = get_db_session()
    occupation_repo = OccupationRepository(entity=OccupationModel)
    occupation_read = occupation_repo.get_category(db, category_id=category_id)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": occupation_read,
    }


@occupation_router.put(
    "/category", response_model=GenericSingleResponse[OccupationCategoryReadSchema], status_code=200
)
# @rbac_access_checker(resource=RBACResource.occupations, rbac_access_type=RBACAccessType.update)
async def update_occupation_category(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    occupation_update: OccupationCategoryUpdateSchema,
    request: Request,
    response: Response,
) -> Any:
    """
    Update an occupation category
    """

    db = get_db_session()
    occupation_repo = OccupationRepository(entity=OccupationModel)
    occupation_updated = occupation_repo.update_category(
        db, filter_obj_in=occupation_update.filter, obj_in=occupation_update.update
    )

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": occupation_updated,
    }


@occupation_router.delete(
    "/category", response_model=GenericSingleResponse[OccupationCategoryReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.occupation, rbac_access_type=RBACAccessType.delete
)
async def delete_occupation_category(
    *,
    filters: Optional[OccupationFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Delete an occupation category.
    """
    db = get_db_session()
    occupation_repo = OccupationRepository(entity=OccupationModel)
    occupation_deleted = occupation_repo.delete_category(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": occupation_deleted,
    }