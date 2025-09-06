import logging
import re
from typing import TypeVar, Annotated

from fastapi import Depends, status, Header
from sqlalchemy import create_engine
from sqlalchemy.exc import DBAPIError, IntegrityError
from sqlalchemy.orm import sessionmaker, declarative_base, Session
from starlette.requests import Request

from core.context_vars import (
    context_db_session,
    context_log_meta,
    context_actor_user_data,
    context_set_db_session_rollback,
)
from core.security import decode_user_access_token, decode_user_refresh_token
from core.security import settings
from logger import logger
from schemas.base import BaseGenericResponse
from schemas.userschema import UserTokenSchema, UserFilterSchema
from utils.exceptions import AuthException, AppException

engine = create_engine(settings.DB_URI, pool_size=99)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

DatabaseErrorType = TypeVar("DatabaseErrorType", bound=DBAPIError)


def get_generic_error_response(
    error: DatabaseErrorType | Exception, resource_name: str
):
    try:
        if isinstance(error, IntegrityError):
            return BaseGenericResponse(
                status_code=status.HTTP_409_CONFLICT,
                message=f"conflict on {resource_name} resource",
                error=True,
            )
        else:
            return BaseGenericResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                message=f"internal server error occurred on resource {resource_name}",
            )
    except Exception:
        return BaseGenericResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            message=f"internal server error occurred on resource {resource_name}",
        )


def get_resource_name(statement: str):
    try:
        table_name = re.findall(r"\btable_\S*", statement)[0]
        assert table_name is not None
        entity_name = table_name.split("table_")[1]
        entity_name = entity_name[0 : len(entity_name) - 1]
        assert entity_name is not None and len(entity_name) > 0
        return entity_name
    except Exception:
        return "entity"


def get_resource_name(statement: str):
    try:
        table_name = re.findall(r"\btable_\S*", statement)[0]
        assert table_name is not None
        entity_name = table_name.split("table_")[1]
        entity_name = entity_name[0 : len(entity_name) - 1]
        assert entity_name is not None and len(entity_name) > 0
        return entity_name
    except Exception:
        return "entity"

def get_db_raw():
    db: Session = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_db():
    """this function is used to inject db_session dependency in every rest api request"""
    db: Session = SessionLocal()
    try:
        print(f"""""""""""""""""""""""""db is of type: {type(db)}")  # Debugging log
        yield db
        #  commit the db session if no exception occurs
        #  if context_set_db_session_rollback is set to True then rollback the db session
        if context_set_db_session_rollback.get():
            logging.info("rollback db session")
            db.rollback()
        else:
            db.commit()
    except Exception as e:
        db.rollback()
    finally:
        #  close the db session
        db.close()



from sqlalchemy.orm import Session
from contextvars import ContextVar
import logging

# example of context var with default fallback
context_set_db_session_rollback: ContextVar[bool] = ContextVar("context_set_db_session_rollback", default=False)

def get_dbs():
    db: Session = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def authentication_context(Authorization: Annotated[str, Header()] = None):
    if Authorization is None:
        raise AppException(
            status_code=401,
            message="no / incomplete / expired authentication credentials",
        )
    scheme, _, token = Authorization.partition(" ")
    if not scheme or scheme.lower() != "bearer" or not token:
        raise AppException(
            status_code=401, message="Invalid authorization credentials format"
        )
    decoded_access_token = decode_user_access_token(token)
    if decoded_access_token is None:
        raise AppException(
            status_code=401, message="no / expired authentication credentials"
        )


async def build_request_context(request: Request, db: Session = Depends(get_db)):
    # setting user token data
    bearer = request.headers.get("Authorization")
    # what was string trim on here again
    # why trim if split by space and access last element it works doesnt it?
    # it does and should be perfect but for exhaustive sakes nbr good man
    user_access_token = None
    if bearer:
        user_access_token = bearer.split(" ")[-1].strip()
    if user_access_token is not None:
        user_token = decode_user_access_token(user_access_token)
        if user_token:
            context_actor_user_data.set(user_token)

    # set the db-session in context-var so that we don't have to pass this dependency downstream
    context_db_session.set(db)

    # fetch the token from context and check if the user is active or not
    user_data_from_context: UserTokenSchema = context_actor_user_data.get()
    if user_data_from_context:
        from models import UserModel
        from repositories.user import UserRepository

        user_repo = UserRepository(entity=UserModel)
        user_id = user_data_from_context.id
        user: UserModel = user_repo.get(db, filters=UserFilterSchema(id=user_id))
        if not user:
            raise AuthException(status_code=401, message="invalid credentials")
        if user.deleted_at:
            raise AuthException(status_code=401, message="user is not active")
        context_log_meta.set(
            {
                "user_id": user_data_from_context.id,
                "actor": str(user_data_from_context.role),
            }
        )

    logger.info(extra=context_log_meta.get(), msg="\nrequest_initiated")


def get_db_session() -> Session:
    """common method to get db session from context variable"""
    return context_db_session.get()



def get_db_sessions() -> Session:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
