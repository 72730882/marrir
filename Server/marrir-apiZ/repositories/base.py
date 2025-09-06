from datetime import datetime
import io
import os
import shutil
from typing import Any, Dict, TypeVar, Union, Generic, Type, List, Optional
import uuid
from fastapi import File, Form, Response, UploadFile

from fastapi.encoders import jsonable_encoder
from fastapi.responses import FileResponse, StreamingResponse
import pandas as pd
from pydantic import BaseModel
from sqlalchemy import BinaryExpression, and_, asc, desc, func, select, column, or_, update
from sqlalchemy.orm import Session
from sqlalchemy.sql.operators import like_op

from core.auth import RBACResource, RBAC_MAPPER, RBACAccessType
from core.context_vars import context_set_response_code_message, context_actor_user_data
from models.base import EntityBaseModel
from models.companyinfomodel import CompanyInfoModel
from models.usermodel import UserModel
from schemas.base import BaseGenericResponse
from schemas.jobschema import JobsSearchSchema
from utils.generatepdf import generate_report
import pdfkit

EntityType = TypeVar("EntityType", bound=EntityBaseModel)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)
FilterSchemaType = TypeVar("FilterSchemaType", bound=BaseModel)


class BaseRepository(Generic[EntityType, CreateSchemaType, UpdateSchemaType]):
    entity: Type[EntityType] = NotImplementedError

    def __init__(self, entity: Type[EntityType]):
        self.entity = entity

    def is_allowed_or_is_owner(
        self, entity: EntityType, access_type: RBACAccessType
    ) -> bool:
        user_data = context_actor_user_data.get()
        if user_data is None:
            return False

        # check role
        user_role = user_data.role
        resource = RBACResource(self.entity.get_resource_name(self.entity.__name__))

        if user_role is not None and resource is not None:
            if user_role in RBAC_MAPPER.get(resource).get(access_type, []):
                return True

        email = user_data.email
        phone_number = user_data.phone_number
        if entity.get_owner() != email and entity.get_owner() != phone_number:
            return False
        return True

    def get_by_id(self, db: Session, entity_id: int) -> EntityType:
        entity = db.query(self.entity).filter(self.entity.id == entity_id).first()

        if (
            entity is None
            or self.is_allowed_or_is_owner(entity, RBACAccessType.read) is False
        ):
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} Not Found",
                    status_code=404,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} found",
                    status_code=200,
                )
            )

        return entity

    def get(self, db: Session, filters: FilterSchemaType) -> EntityType:
        ors = []
        filters_dict = filters.__dict__ if filters is not None else {}
        for key in filters_dict:
            if filters_dict.get(key) is not None:
                ors.append((column(key) == filters_dict.get(key)))
        entity = db.query(self.entity).where(or_(*ors)).first()
        if (
            entity is None
            or self.is_allowed_or_is_owner(entity, RBACAccessType.read) is False
        ):
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=404,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.__name__} found",
                    status_code=200,
                )
            )
        return entity

    def get_some(
        self,
        db: Session,
        skip: int,
        limit: int,
        search: Optional[str],
        search_schema: Optional[any],
        start_date: Optional[datetime],
        end_date: Optional[datetime],
        filters: FilterSchemaType,
        # sort_field: Optional[Dict[any, str]] = None,
        # sort_order: str = "asc",
    ) -> List[EntityType]:
        query = db.query(self.entity)

        if search:
            search_filter = self.build_generic_search_filter(
                self.entity, search_schema, search
            )
            if search_filter is not None:
                query = query.filter(search_filter)

        if start_date and end_date:
            query = query.filter(
                and_(
                    self.entity.created_at >= start_date,
                    self.entity.created_at <= end_date,
                )
            )

        filters_conditions = self.build_filters(
            self.entity, filters.__dict__ if filters else {}
        )

        query = query.filter(filters_conditions)

        # if sort_field:
        #     for model, field in sort_field.items():
        #         if sort_order == "asc":
        #             query = query.order_by(getattr(model, field).asc())
        #         else:
        #             query = query.order_by(getattr(model, field).desc())
        
        query = query.order_by(asc(self.entity.updated_at))
                    
        total_count = query.count()

        entities = query.offset(skip).limit(limit).all()

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s not found / not found in the ",
                    status_code=404,
                )
            )
        elif len(entities) == 0:
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
                    count=total_count,
                )
            )
        return entities

    def get_all(
        self, db: Session, filters: Optional[FilterSchemaType]
    ) -> List[EntityType]:
        ors = []
        filters_dict = filters.__dict__ if filters is not None else {}
        for key in filters_dict:
            if filters_dict[key] is not None:
                if isinstance(filters_dict[key], int):
                    ors.append(column(key) == filters_dict[key])
                elif isinstance(filters_dict[key], str):
                    ors.append(like_op(column(key), filters_dict.get(key)))
        entities = db.query(self.entity).where(or_(*ors)).all()

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s not found / not found in the ",
                    status_code=404,
                )
            )
        elif len(entities) == 0:
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
        entities_count = db.query(self.entity).count()

        return entities

    def create(self, db: Session, *, obj_in: CreateSchemaType) -> EntityType | None:
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

    def update(
        self,
        db: Session,
        filter_obj_in: FilterSchemaType,
        obj_in: Union[UpdateSchemaType, Dict[str, Any]],
    ) -> Optional[EntityType]:
        query = update(self.entity)

        entity = self.get(db, filter_obj_in)

        can_not_update = (
            self.is_allowed_or_is_owner(
                entity=entity, access_type=RBACAccessType.update
            )
            is False
        )

        if entity is None or can_not_update:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found while trying to update",
                    status_code=404,
                )
            )
            return None

        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.dict(exclude_unset=True)

        filter_obj_data = jsonable_encoder(filter_obj_in)

        for field in filter_obj_data:
            if filter_obj_data[field] is not None:
                query = query.where(column(field) == filter_obj_data[field])

        query = query.values(update_data).returning("*")

        result = db.execute(query).all()

        if len(result) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"Failed to update {self.entity.get_resource_name(self.entity.__name__)}",
                    status_code=500,
                )
            )

            return None
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} updated successfully",
                    status_code=200,
                )
            )
            db.refresh(entity)
            return entity

    def delete(
        self,
        db: Session,
        filters: FilterSchemaType,
    ) -> Optional[EntityType]:
        entity = self.get(db, filters)

        can_not_delete = (
            self.is_allowed_or_is_owner(
                entity=entity, access_type=RBACAccessType.delete
            )
            is False
        )

        if entity is None or can_not_delete:
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
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} deleted successfully",
                    status_code=200,
                )
            )
            return entity

    def soft_delete(
        self, db: Session, filters: FilterSchemaType
    ) -> Optional[EntityType]:
        entity = self.get(db, filters)

        can_not_self_delete = (
            self.is_allowed_or_is_owner(
                entity=entity, access_type=RBACAccessType.soft_delete
            )
            is False
        )

        if entity is None or can_not_self_delete:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} Not Found",
                    status_code=404,
                )
            )
            return None
        else:
            entity.deleted_at = datetime.now()
            db.add(entity)
            db.commit()
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} soft deleted successfully",
                    status_code=200,
                )
            )
            return entity

    def filter(
        self,
        db: Session,
        *expressions: BinaryExpression,
    ) -> List[EntityType]:
        query = select(self.entity)
        if expressions:
            query = query.where(*expressions)
        entities = list(db.scalars(query))
        if len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s not found / not found in the "
                    f"page specified",
                    status_code=200,
                )
            )
        else:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                )
            )
        return entities

    def check_conflict(self, db: Session, entity: EntityType):
        keys = {
            c.name: any([c.primary_key, c.unique]) for c in entity.__table__.columns
        }
        conditions = [
            getattr(self.entity, key) == getattr(entity, key)
            for key, is_key in keys.items()
            if is_key and getattr(entity, key) is not None
        ]

        if conditions:
            stmt = select(self.entity).where(or_(*conditions))
            stmt_exists = select(stmt.exists())
            return db.scalar(stmt_exists)
        else:
            return False

    def build_filters(self, model, filters_dict):
        conditions = []
        for key, value in filters_dict.items():
            if value is not None:
                field = getattr(model, key, None)
                if field is not None:
                    if isinstance(value, int):
                        conditions.append(field == value)
                    elif isinstance(value, str):
                        conditions.append(field.like(f"%{value}%"))
                    else:
                        conditions.append(field == value)
        return and_(*conditions)

    def build_generic_search_filter(
        self, model, search_schema: Type[BaseModel], search_query: str
    ):
        search_conditions = []
        for field in search_schema.__fields__.keys():
            if hasattr(model, field):
                # Use ilike for case-insensitive search
                search_conditions.append(
                    getattr(model, field).ilike(f"%{search_query}%")
                )
            elif (field == "location" or field == "company_name") and hasattr(
                CompanyInfoModel, field
            ):
                search_conditions.append(
                    getattr(CompanyInfoModel, field).ilike(f"%{search_query}%")
                )
        return or_(*search_conditions) if search_conditions else None

    def convert_to_model(
        self, obj_in: Generic[EntityType, CreateSchemaType, UpdateSchemaType]
    ) -> EntityType:
        obj_in_data = jsonable_encoder(obj_in)
        return self.entity(**obj_in_data)

    def export_to_pdf(
        self, db: Session, *, title: str, filters: FilterSchemaType
    ) -> StreamingResponse:
        entity = self.get(db, filters=filters)
        if not entity:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=200,
                )
            )
            return None
        html_content = generate_report(title, entity)

        # pdf_options = {
        #     "no-images": None,  # Add this option to disable loading images
        #     "print-media-type": None,  # Add this option to simulate print media type
        #     "disable-smart-shrinking": None,  # Add this option to disable smart shrinking
        #     "quiet": None,  # Add this option to suppress wkhtmltopdf's output
        # }

        filename = "cv"
        output_path = f"{filename}.pdf"

        try:
            pdfkit.from_string(
                html_content,
                output_path,
                configuration=pdfkit.configuration(
                    wkhtmltopdf="C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe"
                ),
            )
            response = FileResponse(
                output_path,
                media_type="application/pdf",
                filename=f"{filename}2.pdf",
            )
        except Exception as e:
            print("Error generating pdf")

        return response

    def bulk_upload(
        self,
        db: Session,
        file: UploadFile = File(...),
    ):
        df = pd.read_csv(
            file.file, dtype={"phone_number": str, "height": float, "weight": float}
        ).applymap(lambda x: None if pd.isna(x) or x == "" else x)
        for index, row in df.iterrows():
            entity = row.to_dict()
            for key, value in entity.items():
                if pd.isna(value):
                    if pd.api.types.is_float_dtype(df[key]):
                        entity[key] = None
                    else:
                        entity[key] = None
            db_obj = self.entity(**entity)
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
