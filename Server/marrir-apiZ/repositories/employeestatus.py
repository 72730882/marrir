import base64
import datetime
from typing import Any, Dict, Optional, Union, Generic, List
from fastapi import Request
from fastapi.encoders import jsonable_encoder

from fastapi.templating import Jinja2Templates
from sqlalchemy import BinaryExpression, desc, text
from sqlalchemy.orm import Session
from core.auth import RBACAccessType

from core.context_vars import context_set_response_code_message
from models.cvmodel import CVModel
from models.employeemodel import EmployeeModel
from models.employeestatusmodel import EmployeeStatusModel
from models.usermodel import UserModel
from models.userprofilemodel import UserProfileModel
from repositories.base import (
    BaseRepository,
    EntityType,
)
from schemas.base import BaseGenericResponse
from schemas.employeestatusschema import (
    EmployeeStatusCreateSchema,
    EmployeeStatusFilterSchema,
    EmployeeStatusUpdatePayload,
    EmployeeStatusUpdateSchema,
)


class EmployeeStatusRepository(
    BaseRepository[
        EmployeeStatusModel, EmployeeStatusCreateSchema, EmployeeStatusCreateSchema
    ]
):
    
    def add_employee_status(
        self, db: Session, *, obj_in: EmployeeStatusCreateSchema
    ) -> EntityType | None:
        obj_in_data = jsonable_encoder(obj_in)

        # ✅ Remove None fields before creating db_obj
        obj_in_data = {k: v for k, v in obj_in_data.items() if v is not None}

        db_obj = self.entity(**obj_in_data)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)

        employee = db.query(EmployeeModel).filter_by(user_id=obj_in.user_id).first()

        if not employee:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="Employee not found",
                    status_code=400,
                )
            )
            return

        employee.status = obj_in.status

        if db_obj is not None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message="Employee status updated successfully",
                    status_code=201,
                )
            )

        return db_obj

    def get_employee_status(
        self, db: Session, filters: EmployeeStatusFilterSchema
    ) -> List[EntityType]:
        query = db.query(EmployeeStatusModel)

        if filters.user_id is not None:
            query = query.filter(EmployeeStatusModel.user_id == filters.user_id)

        if filters.id is not None:
            query = query.filter(EmployeeStatusModel.id == filters.id)

        entities = query.all()

        if len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No {self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                    count=0,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                    count=len(entities),
                )
            )

        return entities

    def update(
        self,
        db: Session,
        filter_obj_in: EmployeeStatusFilterSchema,
        obj_in: EmployeeStatusUpdatePayload,
    ) -> Optional[EntityType]:
        entity = db.query(EmployeeStatusModel).filter_by(id=filter_obj_in.id).first()

        if not entity:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True, message="Employee status not found", status_code=400
                )
            )
            return None

        if obj_in.reason:
            entity.reason = obj_in.reason
            db.commit()
        if obj_in.status:
            employee = db.query(EmployeeModel).filter_by(user_id=entity.user_id).first()
            entity.status = obj_in.status
            employee.status = obj_in.status
            db.commit()

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message="Employee status updated successfully",
                status_code=200,
            )
        )

        return entity

    def delete(self, db: Session, filters: EmployeeStatusFilterSchema) -> EntityType:
        entity = self.get(db, filters)

        if entity is None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} Not Found",
                    status_code=404,
                )
            )
            return None
        else:
            db.delete(entity)
            db.commit()
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message="Employee status deleted successfully",
                    status_code=200,
                )
            )
            return entity

    def export_to_pdf_status(
        self,
        db: Session,
        *,
        request: Request,
        title: str,
        filters: EmployeeStatusFilterSchema,
    ):
        templates = Jinja2Templates(directory="templates")
        statuses = (
            db.query(EmployeeStatusModel)
            .filter_by(user_id=filters.user_id)
            .order_by(desc(EmployeeStatusModel.created_at))
            .all()
        )

        if not statuses:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=200,
                )
            )
            return None

        cv = db.query(CVModel).filter_by(user_id=filters.user_id).first()
        qr_code = (
            db.query(UserProfileModel.qr_code)
            .filter_by(user_id=filters.user_id)
            .scalar()
        )
        employee = db.query(EmployeeModel).filter_by(user_id=filters.user_id).first()
        manager = db.query(UserModel).filter_by(id=employee.manager_id).first()

        data = {
            "name": f"{cv.english_full_name}",
            "head_image": f"{cv.head_photo}",
            "nationality": f"{cv.nationality}",
            "representative": f"{manager.first_name} {manager.last_name}",
            "position": f"{cv.occupation}",
            "passport_number": f"{cv.passport_number}",
            "qr_code": base64.b64encode(qr_code).decode("utf-8"),
            "status_reports": statuses,
        }

        file_path = f"status.html"

        template = templates.get_template("StatuRep.html")
        content = template.render(
            request=request,
            data=data,
            base_url="https://api.marrir.com/static",
        )

        return content

    def format_date(value, format="%Y-%m-%d"):
        return value.strftime(format)
