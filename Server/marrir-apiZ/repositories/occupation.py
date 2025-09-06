from typing import Any, Dict, Optional, Union, List
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session

from core.context_vars import context_set_response_code_message
from core.auth import RBACAccessType
from models.occupationcategorymodel import OccupationCategoryModel
from models.occupationmodel import OccupationModel
from repositories.base import (
    BaseRepository,
    CreateSchemaType,
    EntityType,
    UpdateSchemaType,
    FilterSchemaType,
)
from schemas.base import BaseGenericResponse
from schemas.occupationSchema import OccupationCategoryCreateSchema, OccupationCategoryUpdatePayload, OccupationCreateSchema, OccupationFilterSchema, OccupationUpdateSchema


class OccupationRepository(
    BaseRepository[OccupationModel, OccupationCreateSchema, OccupationUpdateSchema]
):
    def get_categories(self, db: Session):
        categories = db.query(OccupationCategoryModel).all()
        
        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message="Occupation categories found",
                status_code=200,
                count=len(categories),
            )
        )
        return categories

    def get_category(self, db: Session, category_id: int):
        category = db.query(OccupationCategoryModel).filter_by(id=category_id).first()
        if not category:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="Occupation category not found",
                    status_code=404,
                )
            )
            return None
        return category

    def get_occupations(self, db: Session, category_id: int):
        return db.query(OccupationModel).filter_by(category_id=category_id).all()
    
    def create_category(self, db: Session, obj_in: OccupationCategoryCreateSchema):
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = OccupationCategoryModel(**obj_in_data)
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
                    message="Occupation Category created successfully",
                    status_code=201,
                )
            )
        return db_obj

    def update_category(self, db: Session, filter_obj_in: OccupationFilterSchema, obj_in: OccupationCategoryUpdatePayload):
        category = db.query(OccupationCategoryModel).filter(filter_obj_in).first()
        
        if not category:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found while trying to update",
                    status_code=404,
                )
            )
            return None
        
        category.name = obj_in.name
        db.commit()
        db.refresh(category)
        return category

    def delete_category(self, db: Session, filters: FilterSchemaType) -> EntityType:
        category = db.query(OccupationCategoryModel).filter_by(id = filters.category_id).first()
        if not category:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found while trying to delete",
                    status_code=404,
                )
            )
            return None
        
        db.delete(category)
        db.commit()
        return category