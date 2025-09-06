from core.context_vars import context_set_response_code_message
from sqlalchemy.orm import Session
from models.agentrecruitmentmodel import AgentRecruitmentModel

from repositories.base import (
    BaseRepository,
    EntityType,
)
from schemas.agentrecruitmentschema import (
    AgentRecruitmentCreateSchema,
    AgentRecruitmentUpdateSchema,
)
from schemas.base import BaseGenericResponse


class AgentRecruitmentRepository(
    BaseRepository[
        AgentRecruitmentModel,
        AgentRecruitmentCreateSchema,
        AgentRecruitmentUpdateSchema,
    ]
):

    def create(
        self, db: Session, *, obj_in: AgentRecruitmentCreateSchema
    ) -> EntityType | None:
        agent_relationships = (
            db.query(AgentRecruitmentModel).filter_by(agent_id=obj_in.agent_id).count()
        )
        if agent_relationships >= 2:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="An agent can have at most 2 relationships with recruitment companies.",
                    status_code=409,
                )
            )
            return None

        recruitment_relationships = (
            db.query(AgentRecruitmentModel)
            .filter_by(recruitment_id=obj_in.recruitment_id)
            .count()
        )
        if recruitment_relationships >= 2:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="A recruitment company can have at most 2 relationships with agents.",
                    status_code=409,
                )
            )
            return None

        new_relationship = AgentRecruitmentModel(
            agent_id=obj_in.agent_id, recruitment_id=obj_in.recruitment_id
        )
        db.add(new_relationship)
        db.commit()
        db.refresh(new_relationship)

        if new_relationship is not None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} created successfully",
                    status_code=201,
                )
            )
        return new_relationship
