from datetime import datetime
from operator import or_
from typing import Any, Dict, Optional, Union, Generic, List
from fastapi import File, UploadFile
from fastapi.encoders import jsonable_encoder
import pandas as pd
from core.auth import RBACAccessType
from core.context_vars import context_set_response_code_message, context_actor_user_data

from sqlalchemy import BinaryExpression, and_, column
from sqlalchemy.sql.operators import like_op
from sqlalchemy.orm import Session
from models.jobmodel import JobModel

from repositories.base import (
    BaseRepository,
    EntityType,
    UpdateSchemaType,
    CreateSchemaType,
    FilterSchemaType,
)
from schemas.base import BaseGenericResponse
from schemas.jobschema import JobCreateSchema, JobUpdateSchema, JobsSearchSchema


class JobRepository(BaseRepository[JobModel, JobCreateSchema, JobUpdateSchema]):

    def get_by_id(self, db: Session, entity_id: int) -> EntityType:
        return super().get_by_id(db, entity_id)

    def get(self, db: Session, filters: FilterSchemaType) -> EntityType:
        return super().get(db, filters)

    def get_some(
        self,
        db: Session,
        skip: int,
        limit: int,
        search: Optional[str],
        search_schema: Optional[any],
        start_date: Optional[str],
        end_date: Optional[str],
        filters: FilterSchemaType,
    ) -> List[EntityType]:
        return super().get_some(
            db,
            skip,
            limit,
            search,
            search_schema,
            start_date,
            end_date,
            filters,
        )

    def get_all(self, db: Session, filters: FilterSchemaType) -> List[EntityType]:
        return super().get_all(db, filters)

    def create(self, db: Session, *, obj_in: JobCreateSchema) -> EntityType | None:
        user = context_actor_user_data.get().id
        obj_in.posted_by = user
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.entity(**obj_in_data)
        exists = self.check_conflict(db, entity=db_obj)
        if exists:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"conflict occurred trying to create {self.entity.get_resource_name(self.entity.__name__)}",
                    status_code=409,
                )
            )
            return None

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
        return db_obj

    def bulk_upload(self, db: Session, *, file: UploadFile = File(...)):
        df = pd.read_excel(file.file).applymap(
            lambda x: None if pd.isna(x) or x == "" else x
        )
        for index, row in df.iterrows():
            entity = row.to_dict()
            for key, value in entity.items():
                if pd.isna(value):
                    if pd.api.types.is_float_dtype(df[key]):
                        entity[key] = None
                    else:
                        entity[key] = None
            obj_in = JobCreateSchema(**entity)
            user_id = context_actor_user_data.get().id
            obj_in.posted_by = user_id
            db_obj = self.entity(**obj_in.dict())

            db.add(db_obj)
            db.commit()
            db.refresh(db_obj)

            if db_obj is None:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=f"{len(df)} {self.entity.get_resource_name(self.entity.__name__)} creation unsuccessful",
                        status_code=400,
                    )
                )
                return

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"{len(df)} {self.entity.get_resource_name(self.entity.__name__)}s created successfully",
                status_code=201,
            )
        )
        return db_obj

    def update(
        self,
        db: Session,
        filter_obj_in: FilterSchemaType,
        obj_in: Union[UpdateSchemaType, Dict[str, Any]],
    ) -> Optional[EntityType]:
        return super().update(db, filter_obj_in, obj_in)

    def delete(self, db: Session, filters: FilterSchemaType) -> EntityType:
        return super().delete(db, filters)

    def soft_delete(self, db: Session, filters: FilterSchemaType) -> EntityType:
        return super().soft_delete(db, filters)

    def filter(self, db: Session, *expressions: BinaryExpression) -> list[EntityType]:
        return super().filter(db, *expressions)

    def check_conflict(self, db: Session, entity: EntityType):
        return super().check_conflict(db, entity)

    def convert_to_model(
        self, obj_in: Generic[EntityType, CreateSchemaType, UpdateSchemaType]
    ) -> EntityType:
        return super().convert_to_model(obj_in)
