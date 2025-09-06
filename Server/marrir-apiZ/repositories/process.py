import base64
import io
from pathlib import Path
from typing import Any, List, Optional
import uuid
import zipfile
from fastapi import HTTPException, Request, UploadFile
from fastapi.responses import FileResponse, StreamingResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from core.context_vars import context_set_response_code_message, context_actor_user_data
from models.assignagentmodel import AssignAgentModel
from models.cvmodel import CVModel
from models.employeemodel import EmployeeModel
from models.processmodel import ProcessModel
from models.usermodel import UserModel
from models.userprofilemodel import UserProfileModel
from repositories.base import (
    BaseRepository,
    EntityType,
)
from schemas.base import BaseGenericResponse
from schemas.enumschema import ProcessStatusSchema
from schemas.processschema import (
    EmployeeProcessSchema,
    ProcessFilterSchema,
    ProcessProgressSchema,
    ProcessUpsertSchema,
    RequesterReadSchema,
)
from utils.uploadfile import uploadFileToLocal


class ProcessRepository(
    BaseRepository[ProcessModel, ProcessUpsertSchema, ProcessUpsertSchema]
):
    def progress(self, db: Session, filters: ProcessFilterSchema) -> Any:
        process = db.query(ProcessModel).filter_by(user_id=filters.user_id).first()
        (
            acceptance_of_application_progress,
            signing_of_contract_progress,
            passport_progress,
            insurance_progress,
            medical_report_progress,
            certificate_of_freedom_progress,
            coc_progress,
            enjaz_slip_to_agents_progress,
            enjaz_slip_for_recruitment_progress,
            worker_file_to_embassy_progress,
            visa_progress,
            worker_file_in_labor_office_progress,
            receive_travel_authorization_code_progress,
            molsa_letter_progress,
            ticket_progress,
            arrive_progress,
        ) = (
            (
                (
                    getattr(process, "acceptance_of_application_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "signing_of_contract_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "passport_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "insurance_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "medical_report_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "certificate_of_freedom_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (getattr(process, "coc_status", None) == ProcessStatusSchema.ACCEPTED)
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "enjaz_slip_to_agents_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "enjaz_slip_for_recruitment_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "worker_file_to_embassy_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (getattr(process, "visa_status", None) == ProcessStatusSchema.ACCEPTED)
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "molsa_letter_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "worker_file_in_labor_office_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "receive_travel_authorization_code_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "ticket_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
            (
                (
                    getattr(process, "arrive_status", None)
                    == ProcessStatusSchema.ACCEPTED
                )
                * 100
                if process
                else 0
            ),
        )

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{self.entity.get_resource_name(self.entity.__name__)}s found",
                status_code=200,
            )
        )

        return ProcessProgressSchema(
            acceptance_of_application_progress=round(
                acceptance_of_application_progress
            ),
            signing_of_contract_progress=round(signing_of_contract_progress),
            passport_progress=round(passport_progress),
            insurance_progress=round(insurance_progress),
            medical_report_progress=round(medical_report_progress),
            certificate_of_freedom_progress=round(certificate_of_freedom_progress),
            coc_progress=round(coc_progress),
            enjaz_slip_to_agents_progress=round(enjaz_slip_to_agents_progress),
            enjaz_slip_for_recruitment_progress=round(
                enjaz_slip_for_recruitment_progress
            ),
            worker_file_to_embassy_progress=round(worker_file_to_embassy_progress),
            visa_progress=round(visa_progress),
            worker_file_in_labor_office_progress=round(
                worker_file_in_labor_office_progress
            ),
            receive_travel_authorization_code_progress=round(
                receive_travel_authorization_code_progress
            ),
            molsa_letter_progress=round(molsa_letter_progress),
            ticket_progress=round(ticket_progress),
            arrive_progress=round(arrive_progress),
        )

    def upsert(
        self,
        db: Session,
        *,
        user_id: uuid.UUID,
        file_type: Optional[str] = None,
        file: Optional[UploadFile] = None,
        file_status: Optional[ProcessStatusSchema] = None,
    ) -> EntityType | None:
        requester_id = context_actor_user_data.get().id
        process = db.query(ProcessModel).filter_by(user_id=user_id).first()

        if process:
            if file_type in [
                "acceptance_of_application",
                "signing_of_contract",
                "passport",
                "insurance",
                "medical_report",
                "certificate_of_freedom",
                "coc",
                "enjaz_slip_to_agents",
                "enjaz_slip_for_recruitment",
                "worker_file_to_embassy",
                "visa",
                "worker_file_in_labor_office",
                "receive_travel_authorization_code",
                "ticket",
                "arrive",
                "molsa_letter",
            ]:
                file_path = uploadFileToLocal(file)
                setattr(process, file_type, file_path)
                setattr(process, file_type + "_status", file_status)

            db.commit()
            db.refresh(process)
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} updated successfully",
                    status_code=200,
                )
            )
            return process
        else:
            process = ProcessModel()
            process.user_id = user_id
            process.requester_id = requester_id
            if file_type in [
                "acceptance_of_application",
                "signing_of_contract",
                "passport",
                "insurance",
                "medical_report",
                "certificate_of_freedom",
                "coc",
                "enjaz_slip_to_agents",
                "enjaz_slip_for_recruitment",
                "worker_file_to_embassy",
                "visa",
                "worker_file_in_labor_office",
                "receive_travel_authorization_code",
                "ticket",
                "molsa_letter",
                "arrive",
            ]:
                file_path = uploadFileToLocal(file)
                setattr(process, file_type, file_path)
                setattr(process, file_type + "_status", file_status)

            db.add(process)
            db.commit()
            db.refresh(process)
            if process is not None:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=False,
                        message=f"{self.entity.get_resource_name(self.entity.__name__)} created successfully",
                        status_code=201,
                    )
                )
            return process

    def get_my_employees_processes(
        self, db: Session, filters: ProcessFilterSchema
    ) -> List[EntityType]:
        query = db.query(EmployeeModel.user_id)

        if filters.manager_id:
            query = query.filter(EmployeeModel.manager_id == filters.manager_id)

        employee_ids = query.all()

        employee_ids = [id[0] for id in employee_ids]

        tasks = [
            "acceptance_of_application",
            "signing_of_contract",
            "passport",
            "insurance",
            "medical_report",
            "certificate_of_freedom",
            "coc",
            "enjaz_slip_to_agents",
            "enjaz_slip_for_recruitment",
            "worker_file_to_embassy",
            "visa",
            "worker_file_in_labor_office",
            "receive_travel_authorization_code",
            "molsa_letter",
            "ticket",
            "arrive",
        ]

        results = []
        user = context_actor_user_data.get()
        for employee_id in employee_ids:
            processes = db.query(ProcessModel).filter_by(user_id=employee_id).all()
            for process in processes:
                agent_status = (
                    db.query(AssignAgentModel)
                    .filter_by(
                        process_id=process.id, user_id=employee_id, requester_id=user.id
                    )
                    .first()
                )

                if process:
                    completed_tasks = sum(
                        (getattr(process, task) is not None) * 100 for task in tasks
                    )
                    average_progress = completed_tasks / len(tasks)
                    user_name = (
                        db.query(UserModel.first_name, UserModel.last_name)
                        .filter_by(id=employee_id)
                        .first()
                    )
                    full_name = f"{user_name[0]} {user_name[1]}" if user_name else None
                    employee = db.query(CVModel).filter_by(user_id=employee_id).first()
                    requester = (
                        db.query(UserModel).filter_by(id=process.requester_id).first()
                    )
                    qr_code = (
                        db.query(UserProfileModel.qr_code)
                        .filter_by(user_id=employee_id)
                        .scalar()
                    )
                    employee_process = EmployeeProcessSchema(
                        id=process.id,
                        user_id=employee_id,
                        user_name=full_name,
                        user_cv=employee,
                        requester_id=process.requester_id,
                        requester=RequesterReadSchema(
                            id=requester.id,
                            first_name=requester.first_name,
                            last_name=requester.last_name,
                            email=requester.email,
                            phone_number=requester.phone_number,
                            role=requester.role,
                            cv=requester.cv,
                            company=requester.company,
                            created_at=requester.created_at,
                        ),
                        progress=average_progress,
                    )
                    employee_process.assign_agent_status = (
                        agent_status.status if agent_status else None
                    )
                    employee_process.assign_agent_id = (
                        agent_status.id if agent_status else None
                    )

                    results.append(employee_process)

        return results

    def export_to_pdf_process(
        self, db: Session, *, request: Request, title: str, filters: ProcessFilterSchema
    ):
        templates = Jinja2Templates(directory="templates")
        entities = (
            db.query(ProcessModel).filter_by(requester_id=filters.manager_id).all()
        )
        if not entities:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=200,
                )
            )
            return None

        processes = []

        for process in entities:
            cv = db.query(CVModel).filter_by(user_id=process.user_id).first()
            qr_code = (
                db.query(UserProfileModel.qr_code)
                .filter_by(user_id=process.user_id)
                .scalar()
            )

            processes.append(
                {
                    "name": f"{cv.english_full_name}",
                    "passport_number": f"{cv.passport_number}",
                    "qr_code": base64.b64encode(qr_code).decode("utf-8"),
                }
            )

        file_path = f"process.html"

        template = templates.get_template("ProcessBar.html")
        content = template.render(
            request=request,
            processes=processes,
            base_url="https://api.marrir.com/static",
        )

        return content

    # def additionalFile(
    #     self,
    #     db: Session,
    #     *,
    #     user_id: uuid.UUID,
    #     file_name: Optional[str],
    #     file: UploadFile,
    # ) -> EntityType | None:
    #     process = db.query(ProcessModel).filter_by(user_id=user_id).first()

    #     # db.query(ProcessAdditionalFileModel).filter(
    #     #     ProcessAdditionalFileModel.process_id == process.id
    #     # ).delete()

    #     file_path = uploadFileToLocal(file)
    #     new_file = ProcessAdditionalFileModel(
    #         file_name=file_name,
    #         file_path=file_path,
    #         process_id=process.id,
    #     )

    #     db.add(new_file)
    #     db.commit()
    #     db.refresh(new_file)

    #     if new_file is not None:
    #         context_set_response_code_message.set(
    #             BaseGenericResponse(
    #                 error=False,
    #                 message=f"{self.entity.get_resource_name(self.entity.__name__)} added successfully",
    #                 status_code=201,
    #             )
    #         )

    #     return process
