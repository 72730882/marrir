from typing import Any, Optional
from fastapi import APIRouter, Depends, HTTPException, Response, BackgroundTasks
from fastapi.security import HTTPBearer
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.agentrecruitmentmodel import AgentRecruitmentModel
from models.assignagentmodel import AssignAgentModel
from models.companyinfomodel import CompanyInfoModel
from models.notificationmodel import Notifications
from models.db import authentication_context, build_request_context, get_db_session
from repositories.assignagent import AssignAgentRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message, context_actor_user_data
from schemas.assignagentschema import (
    AgentRecruitmentStatusSchema,
    AssignAgentCreateSchema,
    AssignAgentFilterSchema,
    AssignAgentReadSchema,
    AssignAgentUpdateSchema,
    StartedAgentProcessCreateSchema,
    StartedAgentProcessReadSchema,
)
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from utils.send_email import send_email
import logging

logger = logging.getLogger(__name__)

assign_agent_router_prefix = version_prefix + "assign_agent"

assign_agent_router = APIRouter(prefix=assign_agent_router_prefix)

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

@assign_agent_router.post(
    "/",
    response_model=GenericSingleResponse[AssignAgentReadSchema],
    status_code=201,
)
@rbac_access_checker(
    resource=RBACResource.assign_agent, rbac_access_type=RBACAccessType.create
)
async def add_assign_agent_request(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    assign_agent_in: AssignAgentCreateSchema,
    request: Request,
    response: Response,
):
    """
    add assign agent request
    """
    db = get_db_session()
    assign_agent_repo = AssignAgentRepository(entity=AssignAgentModel)
    assign_agent_requested = assign_agent_repo.create(db=db, obj_in=assign_agent_in)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": assign_agent_requested,
    }


@assign_agent_router.post(
    "/start",
    response_model=GenericSingleResponse[StartedAgentProcessReadSchema],
    status_code=201,
)
@rbac_access_checker(
    resource=RBACResource.assign_agent, rbac_access_type=RBACAccessType.create
)
async def agent_start_process(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    start_agent_process_in: StartedAgentProcessCreateSchema,
    request: Request,
    response: Response,
):
    """
    start agent process
    """
    db = get_db_session()
    assign_agent_repo = AssignAgentRepository(entity=AssignAgentModel)
    agent_process_requested = assign_agent_repo.agent_create(
        db=db, obj_in=start_agent_process_in
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": agent_process_requested,
    }


@assign_agent_router.post(
    "/requests/sent",
    response_model=GenericMultipleResponse[AssignAgentReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.assign_agent, rbac_access_type=RBACAccessType.read_multiple
)
async def read_assign_agent_requests_sent(
    *,
    skip: int = 0,
    limit: int = 10,
    filters: Optional[AssignAgentFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve paginated agent assign requests sent.
    """
    db = get_db_session()
    assign_agent_repo = AssignAgentRepository(entity=AssignAgentModel)
    assign_agent_read = assign_agent_repo.get_agent_assign_requests_sent(
        db, filters=filters
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": assign_agent_read,
        "count": res_data.count,
    }


@assign_agent_router.post(
    "/requests/received",
    response_model=GenericMultipleResponse[AssignAgentReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.assign_agent, rbac_access_type=RBACAccessType.read_multiple
)
async def read_assign_agent_requests_received(
    *,
    skip: int = 0,
    limit: int = 10,
    filters: Optional[AssignAgentFilterSchema] = None,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    # _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve paginated agent assign requests received.
    """
    db = get_db_session()
    assign_agent_repo = AssignAgentRepository(entity=AssignAgentModel)
    assign_agent_read = assign_agent_repo.get_agent_assign_requests_received(
        db, skip=skip, limit=limit, filters=filters
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": assign_agent_read,
        "count": res_data.count,
    }


@assign_agent_router.post(
    "/processes",
    response_model=GenericMultipleResponse[StartedAgentProcessReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.assign_agent, rbac_access_type=RBACAccessType.read_multiple
)
async def read_startable_agent_processes(
    *,
    skip: int = 0,
    limit: int = 10,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    # _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response,
) -> Any:
    """
    Retrieve paginated startable agent processes.
    """
    db = get_db_session()
    assign_agent_repo = AssignAgentRepository(entity=AssignAgentModel)
    assign_agent_read = assign_agent_repo.get_agent_processes(
        db, skip=skip, limit=limit
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": assign_agent_read,
        "count": res_data.count,
    }


@assign_agent_router.put(
    "/", response_model=GenericSingleResponse[AssignAgentReadSchema], status_code=200
)
# @rbac_access_checker(resource=RBACResource.users, rbac_access_type=RBACAccessType.update)
async def update_assign_agent_request(
    *,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    status_update: AssignAgentUpdateSchema,
    request: Request,
    response: Response,
) -> Any:
    """
    Update agent assignment request.

    """
    db = get_db_session()
    assign_agent_repo = AssignAgentRepository(entity=AssignAgentModel)
    assign_agent_updated = assign_agent_repo.accept_or_decline_assign_request(
        db, filter_obj_in=status_update.filter, obj_in=status_update.update
    )
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": assign_agent_updated,
    }


@assign_agent_router.get("/admin/agent-recruitment")
async def get_agent_recruitment_requests(
    *,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),

):
    db = get_db_session()

    user = context_actor_user_data.get()

    role = user.role

    if role != "admin":
        return Response(status_code=403, content="You are not authorized to perform this action")

    agent_recruitment = db.query(AgentRecruitmentModel).all()

    agent_recruitment_data = []

    for agent in agent_recruitment:
        agent_company = db.query(CompanyInfoModel).filter(CompanyInfoModel.user_id == agent.agent_id).first()

        recruitment_company = db.query(CompanyInfoModel).filter(CompanyInfoModel.user_id == agent.recruitment_id).first()

        agent_recruitment_data.append(
            {
                "id": agent.id,
                "agent_id": agent.agent_id,
                "agent_name": agent_company.company_name,
                "recruitment_id": agent.recruitment_id,
                "recruitment_name": recruitment_company.company_name,
                "status": agent.status,
                "document_url": agent.document_url,
            }
        )


    return {"status": "success", "data": agent_recruitment_data}


@assign_agent_router.post("/admin/status")
async def update_assign_agent_request(
    *,
    data: AgentRecruitmentStatusSchema,
    background_tasks: BackgroundTasks,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    __=Depends(build_request_context),

):
    try:
        db = get_db_session()

        user = context_actor_user_data.get()

        role = user.role

        if role != "admin":
            return Response(status_code=403, content="You are not authorized to perform this action")

        agent_recruitment = db.query(AgentRecruitmentModel).filter(
            AgentRecruitmentModel.id == data.agent_recruitment_id
        ).first()

        if not agent_recruitment:
            return Response(status_code=404, content="Agent recruitment not found")

        agent_recruitment.status = data.status

        db.commit()

        title = f"Agent Recruitment Status Update"
        description = f"Admin has updated the status of your agent recruitment request to {data.status}."

        background_tasks.add_task(
            send_notification, db, agent_recruitment.agent_id, title, description, "agent_recruitment"
        )
        background_tasks.add_task(
            send_email, agent_recruitment.agent_id, title, description
        )
        background_tasks.add_task(
            send_notification, db, agent_recruitment.recruitment_id, title, description, "agent_recruitment"
        )
        background_tasks.add_task(
            send_email, agent_recruitment.recruitment_id, title, description
        )
        return {"status": "success", "message": "Agent recruitment status updated"}
    except Exception as e:
        print(e)
        db.rollback()
        return Response(status_code=500, content="Failed to update agent recruitment status")
    