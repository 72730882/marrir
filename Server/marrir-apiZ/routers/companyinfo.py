import json
from typing import Any, List, Optional, Annotated
from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, Response, UploadFile, BackgroundTasks
from fastapi.responses import StreamingResponse
from pydantic import ValidationError
from starlette.requests import Request
from core.auth import RBACAccessType, RBACResource, rbac_access_checker
from models.agentrecruitmentmodel import AgentRecruitmentModel
from models.companyinfomodel import CompanyInfoData, CompanyInfoModel
from models.notificationmodel import Notifications
from models.db import authentication_context, build_request_context, get_db_session
from models.usermodel import UserModel
from repositories.agentrecruitment import AgentRecruitmentRepository
from repositories.companyinfo import CompanyInfoRepository
from routers import version_prefix
from core.context_vars import context_set_response_code_message, context_actor_user_data
from schemas.base import GenericMultipleResponse, GenericSingleResponse
from schemas.companyinfoschema import CompanayInfoProgressSchema, CompanyInfoFilterSchema, CompanyInfoReadSchema
from fastapi.security import HTTPBearer
from utils.send_email import send_email
import logging

from utils.uploadfile import uploadFileToLocal

logger = logging.getLogger(__name__)

company_info_router_prefix = version_prefix + "company_info"

company_info_router = APIRouter(prefix=company_info_router_prefix)


# def send_notification(db, user_id, title, description, type):
#     notification = Notifications(
#         title=title,
#         description=description,
#         type=type,
#         user_id=user_id,
#     )
#     db.add(notification)

#     try:
#         db.commit()
#     except Exception as e:
#         logger.error(f"Failed to send notification: {e}")
#         db.rollback()

import logging
# Setup logger (ideally do this at the top of your main application file)
logger = logging.getLogger("uvicorn.app")  # or use __name__
logger.setLevel(logging.INFO)

@company_info_router.post(
    "/", response_model=GenericSingleResponse[CompanyInfoReadSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.company_info, rbac_access_type=RBACAccessType.create
)

async def create_update_company_info(
    request: Request,
    response: Response,
    company_info_data_json: str = Form(...),
    company_license: UploadFile | None = Form(None),
    company_logo: UploadFile | None = Form(None),
    _: dict = Depends(authentication_context),
    __: dict = Depends(build_request_context),
) -> dict:
    """
    Create or update a company info entry.
    """

    try:
        # ✅ Parse JSON string into Python dict
        company_info_dict = json.loads(company_info_data_json)
        company_info_data = CompanyInfoData.parse_obj(company_info_dict)
    except (ValidationError, json.JSONDecodeError) as e:
        logger.error(f"Invalid company_info_data_json: {e}")
        raise HTTPException(status_code=422, detail="Invalid company info data JSON")

    logger.info(f"Received company_license: {company_license.filename if company_license else 'None'}")
    logger.info(f"Received company_logo: {company_logo.filename if company_logo else 'None'}")

    # ✅ Get DB session
    try:
        db = get_db_session()
    except Exception as e:
        logger.error(f"Database session error: {e}")
        raise HTTPException(status_code=500, detail="Database connection failed")

    # ✅ Perform upsert
    try:
        company_info_repo = CompanyInfoRepository(entity=CompanyInfoModel)
        new_company_info = company_info_repo.upsert(
            db=db,
            company_data_json=company_info_data.model_dump(),
            company_license=company_license,
            company_logo=company_logo
        )
    except Exception as e:
        logger.error(f"Error during company info upsert: {e}")
        raise HTTPException(status_code=500, detail="Failed to create/update company info")

    # ✅ Get response metadata from context
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code

    logger.info(
        f"Returning response: status={res_data.status_code}, message={res_data.message}, error={res_data.error}"
    )

    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": new_company_info,
    }



@company_info_router.post(
    "/progress", response_model=GenericSingleResponse[CompanayInfoProgressSchema], status_code=200
)
@rbac_access_checker(
    resource=RBACResource.company_info, rbac_access_type=RBACAccessType.read
)
async def get_company_info_progress(
    *,
    filters: Optional[CompanyInfoFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve company_info completion stat.
    """
    db = get_db_session()
    company_info_repo = CompanyInfoRepository(entity=CompanyInfoModel)
    company_info_progress = company_info_repo.progress(db, filters=filters)
    res_data = context_set_response_code_message.get()
    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": company_info_progress,
    }


@company_info_router.post(
    "/single",
    response_model=GenericSingleResponse[CompanyInfoReadSchema],
    status_code=200,
)
@rbac_access_checker(
    resource=RBACResource.company_info, rbac_access_type=RBACAccessType.read
)
async def read_company_info_post(
    *,
    filters: Optional[CompanyInfoFilterSchema] = None,
    _=Depends(authentication_context),
    __=Depends(build_request_context),
    request: Request,
    response: Response
) -> Any:
    """
    Retrieve single company info.
    """
    db = get_db_session()
    user = context_actor_user_data.get()
    company_info_repo = CompanyInfoRepository(entity=CompanyInfoModel)
    filters.user_id = user.id
    company_info_read = company_info_repo.get(db, filters=filters)
    res_data = context_set_response_code_message.get()
    dealer = []
    selectable = []

    try:
        if company_info_read.user.role == "agent":
            agent_recruitment_data: List[AgentRecruitmentModel] = db.query(AgentRecruitmentModel).filter(AgentRecruitmentModel.agent_id == company_info_read.user.id).all()
            for agent in agent_recruitment_data:
                dealer.append({"user_id": agent.recruitment_id, "name": agent.recruitment.company.company_name or agent.recruitment.first_name, "status": agent.status})
            recruitment_data: List[CompanyInfoModel] = db.query(CompanyInfoModel).filter(CompanyInfoModel.user.has(role="recruitment")).all()
            for recruitment in recruitment_data:
                if not any(agent.recruitment_id == recruitment.user_id for agent in agent_recruitment_data):
                    # Check if there is an existing relationship between the agent and the recruitment
                    if not db.query(AgentRecruitmentModel).filter(
                        AgentRecruitmentModel.agent_id == company_info_read.user.id,
                        AgentRecruitmentModel.recruitment_id == recruitment.user_id
                    ).first():
                        selectable.append({"user_id": recruitment.user_id, "name": recruitment.company_name or recruitment.first_name, "role": recruitment.user.role})

        if company_info_read.user.role == "recruitment":
            agent_recruitment_data: List[AgentRecruitmentModel] = db.query(AgentRecruitmentModel).filter(AgentRecruitmentModel.recruitment_id == company_info_read.user.id).all()
            for recruitment in agent_recruitment_data:
                dealer.append({"user_id": recruitment.agent_id, "name": recruitment.agent.company.company_name or recruitment.agent.first_name, "status": recruitment.status})
            agent_data: List[CompanyInfoModel] = db.query(CompanyInfoModel).filter(CompanyInfoModel.user.has(role="agent")).all()
            for agent in agent_data:
                if not any(recruitment.agent_id == agent.user_id for recruitment in agent_recruitment_data):
                    # Check if there is an existing relationship between the recruitment and the agent
                    if not db.query(AgentRecruitmentModel).filter(
                        AgentRecruitmentModel.recruitment_id == company_info_read.user.id,
                        AgentRecruitmentModel.agent_id == agent.user_id
                    ).first():
                        selectable.append({"user_id": agent.user_id, "name": agent.company_name or agent.first_name, "role": agent.user.role})

    except Exception as e:
        print(e)

    response.status_code = res_data.status_code
    return {
        "status_code": res_data.status_code,
        "message": res_data.message,
        "error": res_data.error,
        "data": company_info_read,
        "dealer": dealer,
        "selectable": selectable
    }


@company_info_router.post("/assign-agent-recruitment")
async def assign_agent_recruitment(
    document: Annotated[UploadFile, File()],
    dealer_id: Annotated[str, Form()],
    background_tasks: BackgroundTasks,
    _=Depends(HTTPBearer(scheme_name="bearer")),
    # _=Depends(authentication_context),
    __=Depends(build_request_context),
):
    try:
        db = get_db_session()
        user = context_actor_user_data.get()
        role = user.role
        doc_url = uploadFileToLocal(document)
        dealer: dict = {"user_id": "", "name": "", "status": "pending"}
        
        if role == "agent":
            agent_recruitment = AgentRecruitmentModel(
                agent_id=user.id,
                recruitment_id=dealer_id,
                status="pending",
                document_url=f"static/{doc_url}"
            )

        
        if role == "recruitment":
            agent_recruitment = AgentRecruitmentModel(
                agent_id=dealer_id,
                recruitment_id=user.id,
                status="pending",
                document_url=f"static/{doc_url}"
            )
        db.add(agent_recruitment)
        db.commit()

        admins = db.query(UserModel).filter(UserModel.role == "admin").all()

        title = "New Agent Recruitment Request"
        description = "A new agent recruitment request has been made."

        # for admin in admins:
        #     background_tasks.add_task(
        #         send_notification, db, admin.id, title, description, "agent_recruitment"
        #     )

        #     background_tasks.add_task(
        #         send_email, admin.email, title, description
        #     )

        if role == "agent":
            dealer.update({"user_id": agent_recruitment.recruitment_id, "name": agent_recruitment.recruitment.company.company_name or agent_recruitment.recruitment.first_name, "status": agent_recruitment.status})
        if role == "recruitment":
            dealer.update({"user_id": agent_recruitment.agent_id, "name": agent_recruitment.agent.company.company_name or agent_recruitment.agent.first_name, "status": agent_recruitment.status})
    except Exception as e:
        print(e)
        db.rollback()
        return {"message": "Failed to create a deal"}

    return {"message": "A deal has been created", "data": dealer}
