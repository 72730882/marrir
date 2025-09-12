import json
import boto3
from datetime import datetime, timedelta
from typing import Optional

from jose import jwt
from passlib.context import CryptContext
from pydantic_settings import BaseSettings, SettingsConfigDict
from google.cloud import storage

import logger
from schemas.userschema import UserTokenSchema, UserRoleSchema

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

ALGORITHM = "HS256"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=("test.env", ".env", ".env.prod"), env_file_encoding="utf-8"
    )
    DB_HOST: str
    DB_PORT: str
    DB_INT_PORT: str
    DB_NAME: str
    DB_USER: str
    DB_PASS: str
    DB_URI: str
    JWT_ACCESS_TOKEN_SECRET: str
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int
    JWT_REFRESH_TOKEN_SECRET: str
    JWT_REFRESH_TOKEN_EXPIRE_MINUTES: int
    STRIPE_PUBLISHABLE_KEY: str
    STRIPE_SECRET_KEY: str
    STRIPE_WEBHOOK_SECRET: str
    OAUTH_CLIENT_ID: str
    OAUTH_CLIENT_SECRET: str
    OAUTH_ACCESS_TOKEN_URL: str
    OAUTH_AUTHORIZE_URL: str
    OAUTH_REDIRECT_URI: str = "http://localhost:5173/google/signin"
    EMAIL: str
    APP_PASSWORD: str
    # Add these ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    FACEBOOK_CLIENT_ID: str
    FACEBOOK_CLIENT_ID: str
    FACEBOOK_CLIENT_SECRET: str
    FACEBOOK_REDIRECT_URI: str
    FACEBOOK_CONFIG_ID: str

    TELR_RETURN_URL: str = "http://localhost:5173/replace/payments"
    TELR_TRANSFER_RETURN_URL: str = "http://localhost:5173/replace/transfer-history"
    TELR_PROMOTION_RETURN_URL: str = "http://localhost:5173/replace/promotion"
    TELR_RESERVE_RETURN_URL: str = "http://localhost:5173/replace/reserve-history"
    TELR_EMPLOYEE_PROCESS_RETURN_URL: str = "http://localhost:5173/replace/employee-process"
    TELR_SPONSOR_EMPLOYEE_PROCESS_RETURN_URL: str = "http://localhost:5173/replace/Employee/reserves"
    TELR_JOB_APPLICATION_RETURN_URL: str = "http://localhost:5173/replace/jobs"
    TELR_AUTH_KEY: str = "Mvc2X~scT45#WsKF"
    TELR_STORE_ID: str = "31896"
    TELR_TEST_MODE: int = 1
    FRONTEND_PUBLIC_CV_URL: str = "http://localhost:5173/public/cv"
    BASE_URL: str = "http://localhost:8000"
    # PROFILE_TRANSFER_PRICE: str


settings = Settings()

# s3_client = boto3.client('s3', aws_access_key_id=settings.AWS_ACCESS_KEY, aws_secret_access_key=settings.AWS_SECRET_KEY)
# storage_client = storage.Client.from_service_account_json(settings.GCS_CREDS_JSON)


def encode_user_access_token(
    subject: UserTokenSchema, expires_delta: timedelta = None
) -> str:
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES
        )
    to_encode = {"exp": expire, "sub": str(subject.as_dict())}
    encoded_jwt = jwt.encode(
        to_encode, settings.JWT_ACCESS_TOKEN_SECRET, algorithm=ALGORITHM
    )
    return encoded_jwt


def encode_user_refresh_token(
    subject: UserTokenSchema, expires_delta: timedelta = None
) -> str:
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.JWT_REFRESH_TOKEN_EXPIRE_MINUTES
        )
    to_encode = {"exp": expire, "sub": str(subject.as_dict())}
    encoded_jwt = jwt.encode(
        to_encode, settings.JWT_REFRESH_TOKEN_SECRET, algorithm=ALGORITHM
    )
    return encoded_jwt


def decode_user_access_token(token: str) -> Optional[UserTokenSchema]:
    try:
        decoded_token = jwt.decode(
            token, settings.JWT_ACCESS_TOKEN_SECRET, algorithms=["HS256"]
        )
        token_data = decoded_token.get("sub")

        token_data = json.loads(token_data.replace("'", '"'))

        id = token_data.get("id")
        email = token_data.get("email")
        phone_number = token_data.get("phone_number")
        role = token_data.get("role")

        if id is None or (email is None and phone_number is None) or role is None:
            raise jwt.JWTError("token is invalid")

        access_token = UserTokenSchema(
            id=id, email=email, phone_number=phone_number, role=UserRoleSchema(
                role)
        )
        return access_token
    except Exception as e:
        return None


def decode_user_refresh_token(token: str) -> Optional[UserTokenSchema]:
    try:
        decoded_token = jwt.decode(
            token, settings.JWT_REFRESH_TOKEN_SECRET, algorithms=["HS256"]
        )
        token_data = decoded_token.get("sub")

        token_data = json.loads(token_data.replace("'", '"'))
        id = token_data.get("id")
        email = token_data.get("email")
        phone_number = token_data.get("phone_number")
        role = token_data.get("role")

        if id is None or (email is None and phone_number is None) or role is None:
            raise jwt.JWTError("token is invalid")

        refresh_token = UserTokenSchema(
            id=id, email=email, phone_number=phone_number, role=role
        )

        return refresh_token
    except Exception as e:
        logger.logger.error(e)
        return None


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)
