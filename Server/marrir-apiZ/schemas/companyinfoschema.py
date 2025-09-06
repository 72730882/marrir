from typing import List, Optional, TypeVar
import uuid

from schemas.base import BaseProps


class CompanyInfoBaseSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    alternative_email: Optional[str] = None
    company_name: Optional[str] = None
    alternative_phone: Optional[str] = None
    location: Optional[str] = None
    year_established: Optional[int] = None
    ein_tin: Optional[str] = None
    company_license: Optional[str] = None
    company_logo: Optional[str] = None


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=CompanyInfoBaseSchema)


class CompanyInfoUpsertSchema(CompanyInfoBaseSchema):
    agent_ids: List[uuid.UUID] = []
    recruitment_ids: List[uuid.UUID] = []
   


class CompanyInfoReadSchema(CompanyInfoBaseSchema):
    id: int
    agent_ids: List[uuid.UUID] = []
    recruitment_ids: List[uuid.UUID] = []


class CompanyInfoFilterSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    email: Optional[str] = None


class CompanayInfoProgressSchema(BaseProps):
    company_info_progress: Optional[float]
    company_document_progress: Optional[float]
