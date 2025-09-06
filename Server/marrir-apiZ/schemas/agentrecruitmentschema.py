from enum import Enum, unique
from typing import List, Optional, TypeVar
import uuid

from schemas.base import BaseProps
from schemas.userschema import UserReadSchema


class AgentRecruitmentBaseSchema(BaseProps):
    agent_id: Optional[uuid.UUID] = None
    recruitment_id: Optional[uuid.UUID] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=AgentRecruitmentBaseSchema)


class AgentRecruitmentCreateSchema(AgentRecruitmentBaseSchema):
    agent_id: uuid.UUID
    recruitment_id: uuid.UUID


class AgentRecruitmentReadSchema(AgentRecruitmentBaseSchema):
    agent: UserReadSchema
    recruitment: UserReadSchema


class AgentRecruitmentUpdatePayload(AgentRecruitmentBaseSchema):
    pass

class AgentRecruitmentsFilterSchema(AgentRecruitmentBaseSchema):
    pass

class AgentRecruitmentUpdateSchema(BaseProps):
    filter: AgentRecruitmentsFilterSchema
    update: AgentRecruitmentUpdatePayload


class AgentRecruitmentDeleteSchema(AgentRecruitmentBaseSchema):
    pass
