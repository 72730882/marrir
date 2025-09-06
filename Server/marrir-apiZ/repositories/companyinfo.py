import json
from operator import or_
from typing import Any, Optional
from fastapi import UploadFile
from fastapi.encoders import jsonable_encoder
from sqlalchemy import column
from core.auth import RBACAccessType
from core.context_vars import (
    context_set_response_code_message,
    context_user_id,
    context_actor_user_data,
)

from sqlalchemy.orm import Session
from models.agentrecruitmentmodel import AgentRecruitmentModel
from models.companyinfomodel import CompanyInfoModel
from repositories.agentrecruitment import AgentRecruitmentRepository

from repositories.base import (
    BaseRepository,
    EntityType,
)
from schemas.agentrecruitmentschema import AgentRecruitmentBaseSchema
from schemas.base import BaseGenericResponse
from schemas.companyinfoschema import (
    CompanayInfoProgressSchema,
    CompanyInfoFilterSchema,
    CompanyInfoUpsertSchema,
)
from utils.uploadfile import uploadFileToLocal


class CompanyInfoRepository(
    BaseRepository[CompanyInfoModel, CompanyInfoUpsertSchema, CompanyInfoUpsertSchema]
):
    def progress(self, db: Session, filters: CompanyInfoFilterSchema) -> Any:
        companyInfo = (
            db.query(CompanyInfoModel).filter_by(user_id=filters.user_id).first()
        )

        company_info_fields = [
            "company_name",
            "alternative_email",
            "alternative_phone",
            "location",
            "year_established",
            "ein_tin",
        ]

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"Progress for {self.entity.get_resource_name(self.entity.__name__)} found successfully",
                status_code=200,
            )
        )

        (company_info_progress, company_document_progress) = (
            (
                (
                    sum(
                        getattr(companyInfo, field) is not None
                        for field in company_info_fields
                    )
                    if companyInfo
                    else 0
                )
                / len(company_info_fields)
                * 100
            ),
            (
                (
                    sum(
                        getattr(companyInfo, field) is not None
                        for field in ["company_license", "company_logo"]
                    )
                    if companyInfo
                    else 0
                )
                / 2
                * 100
            ),
        )

        return CompanayInfoProgressSchema(
            company_info_progress=round(company_info_progress),
            company_document_progress=round(company_document_progress),
        )

    def upsert(
        self,
        db: Session,
        *,
        company_data_json: dict,
        company_license: Optional[UploadFile] = None,
        company_logo: Optional[UploadFile] = None,
    ) -> EntityType | None:
        agent_recr_repo = AgentRecruitmentRepository(AgentRecruitmentModel)
        '''
        company_data = json.loads(company_data_json)
        '''
        company_data = company_data_json  # already a dict

        obj_in = CompanyInfoUpsertSchema(**company_data)

        attributes_to_exclude = ["agent_ids", "recruitment_ids"]

        existing_company_info = (
            db.query(CompanyInfoModel).filter_by(user_id=obj_in.user_id).first()
        )

        if existing_company_info:
            for field, value in obj_in.dict(
                exclude_unset=True, exclude=attributes_to_exclude
            ).items():
                setattr(existing_company_info, field, value)

            if company_license:
                existing_company_info.company_license = uploadFileToLocal(
                    company_license
                )

            if company_logo:
                existing_company_info.company_logo = uploadFileToLocal(company_logo)

            try:
                db.query(AgentRecruitmentModel).filter(
                    (AgentRecruitmentModel.agent_id == context_actor_user_data.get().id)
                    | (
                        AgentRecruitmentModel.recruitment_id
                        == context_actor_user_data.get().id
                    )
                ).delete(synchronize_session=False)
                db.commit()
            except Exception:
                db.rollback()
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=False,
                        message="Failed to delete existing relationships",
                        status_code=200,
                    )
                )
                return None

            for recruitment in obj_in.recruitment_ids:
                agent_recruitment_object = AgentRecruitmentBaseSchema(
                    agent_id=context_actor_user_data.get().id,
                    recruitment_id=recruitment,
                )
                agent_recruitment_relationship = agent_recr_repo.create(
                    db=db, obj_in=agent_recruitment_object
                )
                if not agent_recruitment_relationship:
                    context_set_response_code_message.set(
                        BaseGenericResponse(
                            error=True,
                            message="Failed to add agent recruitment relationship",
                            status_code=400,
                        )
                    )
                    return None

            for agent in obj_in.agent_ids:
                agent_recruitment_object = AgentRecruitmentBaseSchema(
                    recruitment_id=context_actor_user_data.get().id, agent_id=agent
                )
                agent_recruitment_relationship = agent_recr_repo.create(
                    db=db, obj_in=agent_recruitment_object
                )
                if not agent_recruitment_relationship:
                    context_set_response_code_message.set(
                        BaseGenericResponse(
                            error=True,
                            message="Failed to add agent recruitment relationship",
                            status_code=400,
                        )
                    )
                    return None

            db.commit()
            db.refresh(existing_company_info)
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} created/updated successfully",
                    status_code=200,
                )
            )
            return existing_company_info
        else:
            new_company_info = CompanyInfoModel(
                **obj_in.dict(exclude=attributes_to_exclude)
            )

            if company_license:
                new_company_info.company_license = uploadFileToLocal(company_license)

            if company_logo:
                new_company_info.company_logo = uploadFileToLocal(company_logo)

            for recruitment in obj_in.recruitment_ids:
                agent_recruitment_object = AgentRecruitmentBaseSchema(
                    agent_id=context_actor_user_data.get().id,
                    recruitment_email=recruitment,
                )
                agent_recruitment_relationship = agent_recr_repo.create(
                    db=db, obj_in=agent_recruitment_object
                )
                if not agent_recruitment_relationship:
                    context_set_response_code_message.set(
                        BaseGenericResponse(
                            error=True,
                            message="Failed to add agent recruitment relationship",
                            status_code=400,
                        )
                    )
                    return None

            for agent in obj_in.agent_ids:
                agent_recruitment_object = AgentRecruitmentBaseSchema(
                    recruitment_id=context_actor_user_data.get().id,
                    agent_id=agent,
                )
                agent_recruitment_relationship = agent_recr_repo.create(
                    db=db, obj_in=agent_recruitment_object
                )
                if not agent_recruitment_relationship:
                    context_set_response_code_message.set(
                        BaseGenericResponse(
                            error=True,
                            message="Failed to add agent recruitment relationship",
                            status_code=400,
                        )
                    )
                    return None

            db.add(new_company_info)
            db.commit()
            db.refresh(new_company_info)
            

            if new_company_info is not None:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=False,
                        message=f"{self.entity.get_resource_name(self.entity.__name__)} created successfully",
                        status_code=201,
                    )
                )

            return new_company_info
