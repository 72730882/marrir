import uuid
from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from schemas.enumschema import ProcessStatusSchema

from .base import EntityBaseModel
from .db import Base


class ProcessModel(Base, EntityBaseModel):
    __tablename__ = "table_processes"
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )
    requester_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("table_users.id"), nullable=False
    )

    
    acceptance_of_application: Mapped[str] = mapped_column(String, nullable=True)
    acceptance_of_application_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    signing_of_contract: Mapped[str] = mapped_column(String, nullable=True)
    signing_of_contract_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    passport: Mapped[str] = mapped_column(String, nullable=True)
    passport_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    insurance: Mapped[str] = mapped_column(String, nullable=True)
    insurance_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    medical_report: Mapped[str] = mapped_column(String, nullable=True)
    medical_report_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    certificate_of_freedom: Mapped[str] = mapped_column(String, nullable=True)
    certificate_of_freedom_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    coc: Mapped[str] = mapped_column(String, nullable=True)
    coc_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    enjaz_slip_to_agents: Mapped[str] = mapped_column(String, nullable=True)
    enjaz_slip_to_agents_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    enjaz_slip_for_recruitment: Mapped[str] = mapped_column(String, nullable=True)
    enjaz_slip_for_recruitment_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    worker_file_to_embassy: Mapped[str] = mapped_column(String, nullable=True)
    worker_file_to_embassy_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    visa: Mapped[str] = mapped_column(String, nullable=True)
    visa_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    worker_file_in_labor_office: Mapped[str] = mapped_column(String, nullable=True)
    worker_file_in_labor_office_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    receive_travel_authorization_code: Mapped[str] = mapped_column(
        String, nullable=True
    )
    receive_travel_authorization_code_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    ticket: Mapped[str] = mapped_column(String, nullable=True)
    ticket_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    molsa_letter: Mapped[str] = mapped_column(String, nullable=True)
    molsa_letter_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    arrive: Mapped[str] = mapped_column(String, nullable=True)
    arrive_status: Mapped[str] = mapped_column(
        String, default=ProcessStatusSchema.NOT_STARTED
    )

    # passport: Mapped[str] = mapped_column(String, nullable=True)
    # medical_report: Mapped[str] = mapped_column(String, nullable=True)
    # coc: Mapped[str] = mapped_column(String, nullable=True)
    # emergency_contact_id: Mapped[str] = mapped_column(String, nullable=True)
    # insurance: Mapped[str] = mapped_column(String, nullable=True)
    # injaz_slip: Mapped[str] = mapped_column(String, nullable=True)
    # visa: Mapped[str] = mapped_column(String, nullable=True)
    # additional_files = relationship("ProcessAdditionalFileModel", back_populates="process", cascade="all, delete", uselist=True)
