from datetime import datetime
from enum import Enum, unique
from typing import List, Optional, TypeVar, Literal
import uuid

from pydantic import BaseModel

from schemas.base import BaseProps
from schemas.enumschema import TransferStatusSchema
from schemas.userschema import UserReadSchema


Status = Literal["pending", "approved"]

class AssignAgentBaseSchema(BaseProps):
    process_id: Optional[int] = None
    agent_id: Optional[uuid.UUID] = None
    requester_id: Optional[uuid.UUID] = None
    user_id: Optional[uuid.UUID] = None
    status: Optional[TransferStatusSchema] = None
    reason: Optional[str] = None

EntityBaseSchema = TypeVar("EntityBaseSchema", bound=AssignAgentBaseSchema)


class AssignAgentCreateSchema(AssignAgentBaseSchema):
    process_id: int
    agent_id: uuid.UUID
    requester_id: uuid.UUID
    user_id: uuid.UUID


class StartedAgentProcessCreateSchema(BaseProps):
    user_id: uuid.UUID
    agent_id: Optional[uuid.UUID] = None
    assign_agent_id: Optional[int] = None
    

class AssignAgentReadSchema(AssignAgentBaseSchema):
    id: int
    agent: UserReadSchema
    requester: UserReadSchema
    user: UserReadSchema
    created_at: Optional[datetime]
    updated_at: Optional[datetime]

class StartedAgentProcessReadSchema(BaseProps):
    agent_id: Optional[uuid.UUID] = None
    agent: Optional[UserReadSchema] = None
    user_id: Optional[uuid.UUID]
    user: Optional[UserReadSchema] = None
    assign_agent_id: Optional[int] = None
    assign_agent: Optional[AssignAgentReadSchema] = None


class AssignAgentUpdatePayload(AssignAgentBaseSchema):
    pass

class AssignAgentFilterSchema(BaseProps):
    id: Optional[int] = None
    process_id: Optional[int] = None
    agent_id: Optional[uuid.UUID] = None
    requester_id: Optional[uuid.UUID] = None
    user_id: Optional[uuid.UUID] = None
    status: Optional[TransferStatusSchema] = None
    
class AssignAgentUpdateSchema(BaseProps):
    filter: AssignAgentFilterSchema
    update: AssignAgentUpdatePayload

class AssignAgentDeleteSchema(AssignAgentBaseSchema):
    pass


class AgentRecruitmentStatusSchema(BaseModel):
    status: Status = "approved"

    agent_recruitment_id: int