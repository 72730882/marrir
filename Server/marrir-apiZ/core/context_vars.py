from contextvars import ContextVar

from sqlalchemy.orm import Session

from schemas.base import BaseGenericResponse
from schemas.userschema import UserTokenSchema

# context_db_session stores db session created for every request


context_db_session: ContextVar[Session | None] = ContextVar('db_session', default=None)
# context_log_meta stores log meta data for every request

context_log_meta: ContextVar[dict] = ContextVar('log_meta', default={})
# context_user_id stores user id coming from client for every request

context_user_id: ContextVar[str | None] = ContextVar('user_id', default=None)
# context_actor_user_data stores user data coming from token for every request

context_actor_user_data: ContextVar[UserTokenSchema | None] = ContextVar('actor_user_data', default=None)
# context_set_db_session_rollback stores flag to rollback db session or not
context_set_db_session_rollback: ContextVar[bool] = ContextVar('set_db_session_rollback', default=False)
# context for response status code and message

context_set_response_code_message: ContextVar[BaseGenericResponse | None] \
    = ContextVar('set_response_code_message', default=None)
