from datetime import datetime
from typing import Optional
from typing import TypeVar, List
import uuid

from pydantic_extra_types.phone_numbers import PhoneNumber
from pydantic import EmailStr
from schemas.base import BaseProps
from schemas.companyinfoschema import CompanyInfoBaseSchema
from schemas.cvschema import CVReadSchema
from schemas.enumschema import ProcessStatusSchema, TransferStatusSchema, UserRoleSchema


class ProcessAdditionalFileSchema(BaseProps):
    file_name: Optional[str] = None
    file_path: Optional[str] = None


class ProcessBaseSchema(BaseProps):
    user_id: Optional[uuid.UUID] = None
    requester_id: Optional[uuid.UUID] = None
    # passport: Optional[str] = None
    # medical_report: Optional[str] = None
    # coc: Optional[str] = None
    # emergency_contact_id: Optional[str] = None
    # insurance: Optional[str] = None
    # injaz_slip: Optional[str] = None
    # visa: Optional[str] = None
    # molsa_letter: Optional[str] = None

    acceptance_of_application: Optional[str] = None
    signing_of_contract: Optional[str] = None
    passport: Optional[str] = None
    insurance: Optional[str] = None
    medical_report: Optional[str] = None
    certificate_of_freedom: Optional[str] = None
    coc: Optional[str] = None
    enjaz_slip_to_agents: Optional[str] = None
    enjaz_slip_for_recruitment: Optional[str] = None
    worker_file_to_embassy: Optional[str] = None
    visa: Optional[str] = None
    worker_file_in_labor_office: Optional[str] = None
    receive_travel_authorization_code: Optional[str] = None
    ticket: Optional[str] = None
    arrive: Optional[str] = None
    molsa_letter: Optional[str] = None

    acceptance_of_application_status: Optional[ProcessStatusSchema] = None
    signing_of_contract_status: Optional[ProcessStatusSchema] = None
    passport_status: Optional[ProcessStatusSchema] = None
    insurance_status: Optional[ProcessStatusSchema] = None
    medical_report_status: Optional[ProcessStatusSchema] = None
    certificate_of_freedom_status: Optional[ProcessStatusSchema] = None
    coc_status: Optional[ProcessStatusSchema] = None
    enjaz_slip_to_agents_status: Optional[ProcessStatusSchema] = None
    enjaz_slip_for_recruitment_status: Optional[ProcessStatusSchema] = None
    worker_file_to_embassy_status: Optional[ProcessStatusSchema] = None
    visa_status: Optional[ProcessStatusSchema] = None
    worker_file_in_labor_office_status: Optional[ProcessStatusSchema] = None
    receive_travel_authorization_code_status: Optional[ProcessStatusSchema] = None
    ticket_status: Optional[ProcessStatusSchema] = None
    arrive_status: Optional[ProcessStatusSchema] = None
    molsa_letter_status: Optional[ProcessStatusSchema] = None

    # additional_files: Optional[List[ProcessAdditionalFileSchema]] = []


EntityBaseSchema = TypeVar("EntityBaseSchema", bound=ProcessBaseSchema)


class ProcessUpsertSchema(ProcessBaseSchema):
    pass


class ProcessReadSchema(ProcessBaseSchema):
    id: int
    updated_at: Optional[datetime]
    created_at: Optional[datetime]

class RequesterReadSchema(BaseProps):
    id: Optional[uuid.UUID]
    first_name: Optional[str]
    last_name: Optional[str]
    email: Optional[EmailStr]
    phone_number: Optional[PhoneNumber]
    role: UserRoleSchema
    cv: Optional[CVReadSchema] = None
    company: Optional[CompanyInfoBaseSchema] = None
    created_at: datetime
    

class EmployeeProcessSchema(ProcessBaseSchema):
    id: int
    user_id: uuid.UUID
    user_name: Optional[str] = None
    user_cv: Optional[CVReadSchema] = None
    requester_id: uuid.UUID
    requester: Optional[RequesterReadSchema] = None
    qr_code: Optional[bytes] = None
    assign_agent_id: Optional[int] = None
    assign_agent_status: Optional[TransferStatusSchema | None] = None
    progress: float

class ProcessFilterSchema(BaseProps):
    id: Optional[int] = None
    email: Optional[str] = None
    user_id: Optional[uuid.UUID] = None
    manager_id: Optional[uuid.UUID] = None


class ProcessProgressSchema(BaseProps):
    # passport_progress: Optional[float]
    # medical_report_progress: Optional[float]
    # coc_progress: Optional[float]
    # insurance_progress: Optional[float]
    # emergency_contact_id_progress: Optional[float]
    # injaz_slip_progress: Optional[float]
    # visa_progress: Optional[float]

    acceptance_of_application_progress: Optional[float]
    signing_of_contract_progress: Optional[float]
    passport_progress: Optional[float]
    insurance_progress: Optional[float]
    medical_report_progress: Optional[float]
    certificate_of_freedom_progress: Optional[float]
    coc_progress: Optional[float]
    enjaz_slip_to_agents_progress: Optional[float]
    enjaz_slip_for_recruitment_progress: Optional[float]
    worker_file_to_embassy_progress: Optional[float]
    visa_progress: Optional[float]
    worker_file_in_labor_office_progress: Optional[float]
    receive_travel_authorization_code_progress: Optional[float]
    molsa_letter_progress: Optional[float]
    ticket_progress: Optional[float]
    arrive_progress: Optional[float]
