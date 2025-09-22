from fastapi import Response
from uuid import UUID
from fastapi import Request
from fastapi.staticfiles import StaticFiles
import shutil
from fastapi.responses import JSONResponse
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
import logging
from sqlalchemy.orm import Session
from http.client import HTTPException
from typing import Any, List, Optional, Annotated
from urllib import response
import uuid

from fastapi import APIRouter, Depends, Response, Header, UploadFile
from fastapi.security import HTTPBearer

from pydantic import EmailStr
import requests
from starlette.requests import Request
from fastapi import File, Form, UploadFile
from authlib.integrations.starlette_client import OAuth
from core.auth import rbac_access_checker, RBACResource, RBACAccessType
from core.context_vars import context_set_response_code_message
from core.security import Settings
import os
from models.db import build_request_context, get_db, get_db_session, authentication_context, get_dbs
from models.usermodel import UserModel
from repositories.user import UserRepository, send_emails
from routers import version_prefix
from schemas.base import GenericSingleResponse, GenericMultipleResponse, BaseGenericResponse
from schemas.cvschema import CVSearchSchema
from schemas.userschema import (
    AdminUsersSearchSchema,
    EmailRequest,
    EmployeeReadSchema,
    OTPRequest,
    PasswordResetRequest,
    RedactedEmployeeReadSchema,
    UploadTermsRequest,
    UserBaseSchema,
    UserCVFilterSchema,
    UserCreateSchema,
    UserReadSchema,
    UsersFilterSchema,
    UserFilterSchema,
    UserUpdateSchema,
    UserLoginSchema,
    UserTokenResponseSchema,
    UsersSearchSchema,
)

settings = Settings()

oauth = OAuth()

# Configure Google OAuth2
oauth.register(
    name="google",
    client_id=settings.OAUTH_CLIENT_ID,
    client_secret=settings.OAUTH_CLIENT_SECRET,
    access_token_url=settings.OAUTH_ACCESS_TOKEN_URL,
    authorize_url=settings.OAUTH_AUTHORIZE_URL,
    client_kwargs={"scope": "openid email profile"},
)
user_router_prefix = version_prefix + "user"
user_router = APIRouter(prefix=user_router_prefix)


oauth.register(
    name='facebook',
    client_id=os.getenv("FACEBOOK_CLIENT_ID"),
    client_secret=os.getenv("FACEBOOK_CLIENT_SECRET"),
    access_token_url='https://graph.facebook.com/v10.0/oauth/access_token',
    access_token_params=None,
    authorize_url='https://www.facebook.com/v10.0/dialog/oauth',
    authorize_params=None,
    api_base_url='https://graph.facebook.com/',
    client_kwargs={'scope': 'email'},
)


@user_router.post(
    "/login",
    response_model=GenericSingleResponse[UserTokenResponseSchema],
    status_code=200,
)
async def login_user(
    *,
    user_in: UserLoginSchema,
    _=Depends(build_request_context),
    request: Request,
    response: Response,
):
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_token = user_repo.authenticate(db, user_in)
    # If authentication failed, return early
    if not user_token:
        response.status_code = 404
        return {
            "status_code": 404,
            "message": "The email or password is incorrect!",
            "error": True,
            "data": None,
        }
    # Fetch full user object
    user = db.query(UserModel).filter(UserModel.email == user_in.email).first()
    # Default response values
    res_data = context_set_response_code_message.get()
    if not user:
        response.status_code = 404
        return {
            "status_code": 404,
            "message": "User not found.",
            "error": True,
            "data": None,
        }

    if user.role == "admin":  # or use UserRole.ADMIN if using enums
        response.status_code = 200
        return {
            "status_code": 200,
            "message": "login successful.",
            "error": False,
            "data": user_token,
        }

    if user.role == "selfsponsor":
        user.role = "employee"
        db.commit()
        db.refresh(user)
        response.status_code = 200
        return {
            "status_code": 200,
            "message": "User role updated to employee. Login successful.",
            "error": False,
            "data": user_token,
        }

    if user.role == "employee":  # or use UserRole.ADMIN if using enums
        response.status_code = 200
        return {
            "status_code": 200,
            "message": "Employee login successful.",
            "error": False,
            "data": user_token,
        }



    # if not user.is_uploaded:
    #     response.status_code = 428  # Precondition Required
    #     return {
    #         "status_code": 428,
    #         "message": "Please upload your agreement form before logging in.",
    #         "error": True,
    #         "data": user_token,
    #     }

   

    if user.is_admin_rejected:
        response.status_code = 403  # Forbidden
        return {
            "status_code": 403,
            "message": "Your account has been rejected by admin.",
            "error": True,
            "data": user_token,
        }

    # if not user.is_admin_approved:
    #     response.status_code = 409  # Conflict
    #     return {
    #         "status_code": 409,
    #         "message": "Your account is pending admin approval.",
    #         "error": True,
    #         "data": user_token,
    #     }

    # User is approved and all checks passed
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_token,
    }


@user_router.post("/login/google")
async def login_via_google(request: Request):
    return {
        "url": f"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id={settings.OAUTH_CLIENT_ID}&redirect_uri={settings.OAUTH_REDIRECT_URI}&scope=openid%20profile%20email"
    }


@user_router.post("/login/facebook")
async def login_via_facebook(request: Request):
    return {
        "url": f"https://www.facebook.com/v10.0/dialog/oauth?client_id={os.getenv('FACEBOOK_CLIENT_ID')}&redirect_uri={settings.FACEBOOK_REDIRECT_URI}&scope=email"
    }


@user_router.post("/auth/google")
async def auth_google(
    code: str,
    _=Depends(build_request_context),
):
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    token_url = "https://accounts.google.com/o/oauth2/token"
    data = {
        "code": code,
        "client_id": settings.OAUTH_CLIENT_ID,
        "client_secret": settings.OAUTH_CLIENT_SECRET,
        "redirect_uri": settings.OAUTH_REDIRECT_URI,
        "grant_type": "authorization_code",
    }
    response = requests.post(token_url, data=data)
    access_token = response.json().get("access_token")
    user_info = requests.get(
        "https://www.googleapis.com/oauth2/v1/userinfo",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    user_tokens = user_repo.user_handling_logic(db, user_info.json())
    return user_tokens


@user_router.post("/auth/facebook")
async def auth_facebook(
    code: str,
    _=Depends(build_request_context),
):
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)

    token_url = "https://graph.facebook.com/v10.0/oauth/access_token"
    data = {
        "client_id": os.getenv("FACEBOOK_CLIENT_ID"),
        "redirect_uri": settings.FACEBOOK_REDIRECT_URI,
        "client_secret": os.getenv("FACEBOOK_CLIENT_SECRET"),
        "code": code,
    }

    # Exchange code for access token
    token_response = requests.get(token_url, params=data)
    access_token = token_response.json().get("access_token")

    if not access_token:
        return {"error": "Failed to retrieve access token"}

    # Use access token to get user info
    user_info_response = requests.get(
        "https://graph.facebook.com/me",
        params={"fields": "id,name,email", "access_token": access_token},
    )

    user_info = user_info_response.json()

    # Handle login/registration logic
    user_tokens = user_repo.user_handling_logic(db, user_info)
    return user_tokens


@user_router.get(
    "/refresh", response_model=GenericSingleResponse[UserTokenResponseSchema]
)
async def refresh_token_user(
    request: Request,
    response: Response,
    x_access_token: Annotated[str, Header()] = None,
    x_refresh_token: Annotated[str, Header()] = None,
):
    user_repo = UserRepository(entity=UserModel)
    user_token_data = user_repo.refresh(x_access_token, x_refresh_token)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    if user_token_data:
        response.headers.__setitem__(
            "x-access-token", user_token_data.access_token)
        response.headers.__setitem__(
            "x-refresh-token", user_token_data.refresh_token)
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_token_data,
    }


@user_router.post("/request-reset")
async def request_reset(
    *,
    request_in: EmailRequest,
    _=Depends(build_request_context),
    request: Request,
    response: Response,
):
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_created = user_repo.request_password_reset(db, request_in=request_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_created,
    }


@user_router.post("/resend-otp")
async def resend_otp(
    *,
    request_in: EmailRequest,
    _=Depends(build_request_context),
    request: Request,
    response: Response,
):
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_created = user_repo.resend_otp(db, request_in=request_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_created,
    }


@user_router.post("/verify-otp")
async def verify_otp(
    obj_in: OTPRequest,
    response: Response,
    _=Depends(build_request_context),
):
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_created = user_repo.verify_otp(db, obj_in=obj_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_created,
    }


@user_router.post("/reset-password")
async def reset_password(
    data: PasswordResetRequest,
    response: Response,
    _=Depends(build_request_context),
):
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_created = user_repo.reset_password(db, data=data)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_created,
    }


logging.basicConfig(level=logging.DEBUG)


'''
app = FastAPI()
app.mount("/uploaded_terms", StaticFiles(directory="uploaded_terms"), name="uploaded_terms")
@user_router.post("/upload-terms")
async def upload_terms(email: str = Form(...), terms_file: UploadFile = File(...), db: Session = Depends(get_db)):
    if not email:
        raise HTTPException(status_code=400, detail="Email is required")
    if not terms_file:
        raise HTTPException(status_code=400, detail="Terms file is required")
    user = db.query(UserModel).filter(UserModel.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    upload_directory = "uploaded_terms"
    if not os.path.exists(upload_directory):
        os.makedirs(upload_directory)
    try:
        file_location = os.path.join(upload_directory, f"{uuid.uuid4()}_{terms_file.filename}")
        with open(file_location, "wb") as buffer:
            shutil.copyfileobj(terms_file.file, buffer)
        user.terms_file_path = file_location
        user.is_uploaded = True
        db.commit()
        print('filelocation',  file_location)
        return {
            "message": "Terms uploaded successfully",
            "email": email,
            "file_location": file_location
        }

    except Exception as e:
        db.rollback()  # Rollback in case of an error
        raise HTTPException(status_code=500, detail=f"Error processing file: {str(e)}")
'''


@user_router.post("/upload-terms")
async def upload_terms(
    email: str = Form(...),
    terms_file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    # Validate
    if not email:
        raise HTTPException(status_code=400, detail="Email is required")
    if not terms_file:
        raise HTTPException(status_code=400, detail="Terms file is required")

    # Find user
    user = db.query(UserModel).filter(UserModel.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    upload_directory = "uploaded_terms"
    if not os.path.exists(upload_directory):
        os.makedirs(upload_directory)

    try:
        # Save file
        file_location = os.path.join(
            upload_directory, f"{uuid.uuid4()}_{terms_file.filename}")
        with open(file_location, "wb") as buffer:
            shutil.copyfileobj(terms_file.file, buffer)

        # Update DB
        user.terms_file_path = file_location
        user.is_uploaded = True
        db.commit()

        # # ✅ Send email to admin after successful commit
        # try:
        #     subject = "User Terms Uploaded - Approval Required"
        #     admin_email = "ejtiazportal@gmail.com"
        #     body = (
        #         f"Hello Admin,\n\n"
        #         f"The user {user.first_name} {user.last_name} ({user.email}) "
        #         f"has uploaded their Terms file.\n\n"
        #         f"Please review and approve it in the system.\n\n"
        #         f"File Path: {file_location}\n\n"
        #         f"Thanks,\nMarri Platform"
        #     )
        #     send_emails(to_email=admin_email, subject=subject, body=body)
        # except Exception as e:
        #     print(f"⚠️ Failed to send notification email: {e}")

        return {
            "message": "Terms uploaded successfully",
            "email": email,
            "file_location": file_location,
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500, detail=f"Error processing file: {str(e)}")


'''
@user_router.get("/pending-approvals/{user_id}")
async def get_pending_approval_users(
    user_id: uuid.UUID,
    db: Session = Depends(get_db)
):
    user = db.query(UserModel).filter(UserModel.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    users = db.query(UserModel).filter(
        UserModel.is_uploaded == True,
        UserModel.is_admin_approved == False,
        UserModel.is_admin_rejected == False
    ).all()

    return users
'''


@user_router.get("/pending-approvals")
async def get_pending_approval_users(
    request: Request,
    db: Session = Depends(get_db)
):
    users = db.query(UserModel).filter(
        UserModel.is_uploaded == True,
    ).all()

    base_url = str(request.base_url)

    result = []
    for user in users:
        result.append({
            "id": str(user.id),
            "first_name": user.first_name,
            "last_name": user.last_name,
            "email": user.email,
            "phone_number": user.phone_number,
            "is_uploaded": user.is_uploaded,
            "is_approved": user.is_admin_approved,
            "is_rejected": user.is_admin_rejected,
            "terms_file_path": f"{base_url}{user.terms_file_path}" if user.terms_file_path else None,
            # include other fields as needed
        })

    return result


@user_router.put("/approve/{user_id}")
async def approve_user(user_id: UUID,
                       request: Request,
                       db: Session = Depends(get_db)
                       ):

    user = db.query(UserModel).filter(UserModel.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_admin_approved = True
    user.is_admin_rejected = False

    # ✅ Send confirmation email after user is fully created
    try:
        # User welcome email
        user_email = user.email  # ✅ send to the user's registered email
        subject_user = "Welcome to Marri Platform!"
        body_user = (
            f"Welcome to Marri, {user.first_name}!\n\n"
            "Please visit our platform your account has been approved and ready to go!\n\n"
            "You can log in and get started here: https://marrir.com/\n\n"
            "Your account has been created successfully.\n\nThanks!"
        )
        send_emails(to_email=user_email, subject=subject_user, body=body_user)

    except Exception as e:
        # Optionally log this error
        print(f"Failed to send email: {e}")

    db.commit()

    return {
        "status_code": 200,
        "message": f"User {user.email} approved successfully",
        "error": False
    }


@user_router.put("/reject/{user_id}")
async def reject_user(user_id: UUID,
                      request: Request,
                      db: Session = Depends(get_db)
                      ):

    user = db.query(UserModel).filter(UserModel.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_admin_approved = False
    user.is_admin_rejected = True
    db.commit()

    return {
        "status_code": 200,
        "message": f"User {user.email} approved successfully",
        "error": False
    }


@user_router.post(
    "/", response_model=GenericSingleResponse[UserReadSchema], status_code=201
)
async def create_user(
    *,
    user_in: UserCreateSchema,
    _=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    create a new user.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_created = user_repo.create(db, obj_in=user_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_created,
    }


@user_router.post("/bulk", status_code=201)
async def bulk_create_user(
    *,
    file: UploadFile,
    request: Request,
    response: Response,
    # _=Depends(HTTPBearer(scheme_name="bearer")),
    _=Depends(authentication_context),
    __=Depends(build_request_context),
) -> Any:
    """
    create many new user.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_created = user_repo.bulk_upload(db, file=file)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_created,
    }


@user_router.post(
    "/paginated",
    response_model=GenericMultipleResponse[UserReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.user, rbac_access_type=RBACAccessType.read_multiple
)
async def read_users(
    *,
    filters: Optional[UsersFilterSchema] = None,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10,
    search: str = None,
    start_date: str = None,
    end_date: str = None,
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve users.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    users_read = user_repo.get_some(
        db,
        skip=skip,
        limit=limit,
        search=search,
        search_schema=UsersSearchSchema,
        start_date=start_date,
        end_date=end_date,
        filters=filters,
        # sort_field={UserModel: "first_name", CVModel: "english_full_name"},
        # sort_order="asc",
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": users_read,
        "count": res_data.count,
    }


@user_router.post(
    "/paginated/non-employee",
    response_model=GenericMultipleResponse[UserReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.user, rbac_access_type=RBACAccessType.read_multiple
)
async def read_non_employee_users(
    *,
    filters: Optional[UsersFilterSchema] = None,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),
    skip: int = 0,
    limit: int = 10,
    search: str = None,
    start_date: str = None,
    end_date: str = None,
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve non employee users.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    users_read = user_repo.get_some_non_employee(
        db,
        skip=skip,
        limit=limit,
        search=search,
        search_schema=AdminUsersSearchSchema,
        start_date=start_date,
        end_date=end_date,
        filters=filters,
        # sort_field="first_name",
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": users_read,
        "count": res_data.count,
    }


@user_router.post(
    "/single", response_model=GenericSingleResponse[UserReadSchema], status_code=200
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.read)
async def read_user(
    *,
    filters: Optional[UserFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve user.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_read = user_repo.get(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_read,
    }


@user_router.post(
    "/employee/create",
    response_model=GenericSingleResponse[UserReadSchema],
    status_code=201,
)
async def create_employee(
    *,
    user_in: UserCreateSchema,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    create a new employee.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_created = user_repo.create(db, obj_in=user_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_created,
    }


@user_router.post(
    "/employee",
    response_model=GenericSingleResponse[EmployeeReadSchema],
    status_code=200,
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.read)
async def read_employee(
    *,
    employee_id: uuid.UUID,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve employee.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_read = user_repo.get_employee_detail(
        db, employee_id=employee_id, redacted=False
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_read,
    }


@user_router.post(
    "/employee/redacted",
    response_model=GenericSingleResponse[RedactedEmployeeReadSchema],
    status_code=200,
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.read)
async def read_redacted_employee(
    *,
    employee_id: uuid.UUID,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve redacted employee.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_read = user_repo.get_employee_detail(
        db, employee_id=employee_id, redacted=True
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_read,
    }


@user_router.post(
    "/employees",
    response_model=GenericMultipleResponse[UserReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.user, rbac_access_type=RBACAccessType.read_multiple
)
async def read_managed_users(
    *,
    # _=Depends(HTTPBearer(scheme_name="bearer")),
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    manager_id: uuid.UUID,
    skip: int = 0,
    limit: int = 1000,
    search: str = None,
    start_date: str = None,
    end_date: str = None,
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve managed users.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    users_read = user_repo.get_managed_employees(
        db,
        skip=skip,
        limit=limit,
        search=search,
        search_schema=UsersSearchSchema,
        start_date=start_date,
        end_date=end_date,
        manager_id=manager_id,
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": users_read,
        "count": res_data.count,
    }


@user_router.post(
    "/employees/cv",
    response_model=GenericMultipleResponse[UserReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.user, rbac_access_type=RBACAccessType.read_multiple
)
async def read_managed_user_cvs(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    manager_id: str,
    skip: int = 0,
    limit: int,
    search: str = None,
    start_date: str = None,
    end_date: str = None,
    request: Request,
    response: Response,
    filters: Optional[UserCVFilterSchema] = None,
) -> Any:
    """
    Retrieve managed users.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    users_read = user_repo.get_managed_employee_cv_info(
        db,
        skip=skip,
        limit=limit,
        search=search,
        search_schema=CVSearchSchema,
        start_date=start_date,
        end_date=end_date,
        manager_id=manager_id,
        filters=filters,
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": users_read,
        "count": res_data.count,
    }


@user_router.post("/qr-code", response_model=None, status_code=200)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.read)
async def read_user_qr_code(
    *,
    filters: Optional[UserFilterSchema] = None,
    # _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve user QR code.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_read = user_repo.get_qr_code(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return user_read


@user_router.post(
    "/generate-report",
    response_model=GenericSingleResponse[UserReadSchema],
    status_code=200,
)
@rbac_access_checker(resource=RBACResource.user, rbac_access_type=RBACAccessType.read)
async def generate_user_report(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    filters: Optional[UserFilterSchema] = None,
    request: Request,
    response: Response,
) -> Any:
    """
    generate user report.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_created = user_repo.export_to_pdf(
        db, title="User Info", filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_created,
    }


@user_router.put(
    "/", response_model=GenericSingleResponse[UserReadSchema], status_code=200
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.update)
async def update_user(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    user_update: UserUpdateSchema,
    request: Request,
    response: Response,
) -> Any:
    """
    Update a user
    """

    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_updated = user_repo.update(
        db, filter_obj_in=user_update.filter, obj_in=user_update.update
    )

    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_updated,
    }


@user_router.patch(
    "/verify", status_code=200, response_model=GenericSingleResponse[UserReadSchema]
)
async def verify_user(
    *,
    filters: Optional[UserFilterSchema] = None,
    __=Depends(build_request_context),
    request: Request,
    response: Response,
):
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user = user_repo.verify(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user,
    }


@user_router.post(
    "/profile/view", status_code=200, response_model=None
)
async def view_user_profile(
    *,
    filters: Optional[UserFilterSchema] = None,
    __=Depends(build_request_context),
    request: Request,
    response: Response,
):
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_repo.increment_profile_views(db, filters)
    return


@user_router.delete(
    "/", response_model=GenericSingleResponse[UserReadSchema], status_code=200
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.delete)
async def delete_user(
    *,
    filters: Optional[UserFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Delete a user.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_deleted = user_repo.delete(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_deleted,
    }


@user_router.delete(
    "/suspend", response_model=GenericSingleResponse[UserReadSchema], status_code=200
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.soft_delete)
async def soft_delete_user(
    *,
    filters: Optional[UserFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Soft Delete a user.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_soft_deleted = user_repo.soft_delete(db, filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_soft_deleted,
    }


@user_router.patch(
    "/disable", response_model=GenericSingleResponse[UserReadSchema], status_code=200
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.soft_delete)
async def enable_disable_user(
    *,
    user_id: uuid.UUID,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Enable Disable user.
    """
    db = get_db_session()
    user_repo = UserRepository(entity=UserModel)
    user_disabled = user_repo.disable_enable(db, user_id=user_id)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": user_disabled,
    }
