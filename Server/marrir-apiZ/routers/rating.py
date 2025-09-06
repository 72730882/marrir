from typing import Any, Optional
from fastapi import APIRouter, Depends, Response
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.db import authentication_context, build_request_context, get_db_session
from models.ratingmodel import RatingModel
from repositories.rating import RatingRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.ratingschema import (
    EmployeeRatingFilterSchema,
    RatingCreateSchema,
    RatingFilterSchema,
    RatingReadSchema,
    RatingUpdateSchema,
    UserRatingSchema,
)
from schemas.userschema import EmployeeRatingSchema

rating_router_prefix = version_prefix + "rating"

rating_router = APIRouter(prefix=rating_router_prefix)


@rating_router.post(
    "/",
    response_model=GenericSingleResponse[RatingReadSchema],
    status_code=201,
)
@rbac_access_checker(
    resource=RBACResource.rating, rbac_access_type=RBACAccessType.create
)
async def rate(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    rating_in: RatingCreateSchema,
    request: Request,
    response: Response
):
    """
    Add a rating
    """
    db = get_db_session()
    rating_repo = RatingRepository(entity=RatingModel)
    rating_requested = rating_repo.add_rating(db, obj_in=rating_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": rating_requested,
    }


@rating_router.post(
    "/user",
    response_model=GenericSingleResponse[UserRatingSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.rating, rbac_access_type=RBACAccessType.read_multiple
)
async def view_user_rating(
    *,
    filters: Optional[RatingFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve rating.
    """
    db = get_db_session()
    rating_repo = RatingRepository(entity=RatingModel)
    ratings_read = rating_repo.get_user_ratings(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": ratings_read,
    }
    

@rating_router.post(
    "/employees",
    response_model=GenericMultipleResponse[EmployeeRatingSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.rating, rbac_access_type=RBACAccessType.read_multiple
)
async def view_employees_ratings(
    *,
    filters: Optional[EmployeeRatingFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve my employee's ratings.
    """
    db = get_db_session()
    rating_repo = RatingRepository(entity=RatingModel)
    ratings_read = rating_repo.get_my_employees_ratings(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code

    for rating in ratings_read:
        if rating.user and rating.user.references:
            rating.ratings.self_rating += 1
        
        if rating.user and rating.user.additional_languages:
            if len(rating.user.additional_languages) > 2:
                rating.ratings.self_rating += 1.5
            elif len(rating.user.additional_languages) == 2:
                rating.ratings.self_rating += 1
            else:
                rating.ratings.self_rating += 0.5

        if rating.user and rating.user.work_experiences:
            if len(rating.user.work_experiences) >= 2:
                rating.ratings.self_rating += 2
            elif len(rating.user.work_experiences) == 1:
                rating.ratings.self_rating += 1

    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": ratings_read,
    }


@rating_router.put(
    "/", response_model=GenericSingleResponse[RatingReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.rating, rbac_access_type=RBACAccessType.update
)
async def update_rating(
    *,
    rating_in: RatingUpdateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    update rating
    """
    db = get_db_session()
    rating_repo = RatingRepository(entity=RatingModel)
    review_rating = rating_repo.update_rating(
        db, filter_obj_in=rating_in.filter, obj_in=rating_in.update
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": review_rating,
    }


@rating_router.delete(
    "/", response_model=GenericSingleResponse[RatingReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.rating, rbac_access_type=RBACAccessType.delete
)
async def delete_rating(
    *,
    filters: Optional[RatingFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Delete a rating.
    """
    db = get_db_session()
    rating_repo = RatingRepository(entity=RatingModel)
    rating_deleted = rating_repo.delete(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": rating_deleted,
    }
