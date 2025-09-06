from typing import List
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session
from models.jobapplicationmodel import JobApplicationModel
from core.context_vars import context_set_response_code_message

from repositories.base import BaseRepository, EntityType, FilterSchemaType
from schemas.base import BaseGenericResponse
from schemas.jobschema import (
    ApplyJobMultipleBaseSchema,
    ApplyJobReadSchema,
    ApplyJobSingleBaseSchema,
)


class JobApplicationRepository(
    BaseRepository[JobApplicationModel, ApplyJobMultipleBaseSchema, None]
):
    def apply(
        self, db: Session, *, obj_in: ApplyJobMultipleBaseSchema
    ) -> List[ApplyJobReadSchema]:
        job_applications = []
        for user_id in obj_in.user_id:
            single_job_application = ApplyJobSingleBaseSchema(
                job_id=obj_in.job_id, user_id=user_id, status=obj_in.status
            )
            obj_in_data = jsonable_encoder(single_job_application)
            db_obj = self.entity(**obj_in_data)
            exists = (
                db.query(JobApplicationModel)
                .filter_by(job_id=db_obj.job_id, user_id=db_obj.user_id)
                .first()
            )
            if exists:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=f"You have already applied for this job!",
                        status_code=409,
                    )
                )
                return []
            db.add(db_obj)
            db.commit()
            db.refresh(db_obj)

            if db_obj is not None:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=False,
                        message=f"{self.entity.get_resource_name(self.entity.__name__)} created successfully",
                        status_code=201,
                    )
                )
            job_applications.append(db_obj)
        return job_applications

    
    def delete(self, db: Session, filters: FilterSchemaType) -> EntityType:
        return super().delete(db, filters)
