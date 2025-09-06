from datetime import datetime
from typing import Any, Dict, List, Optional, Union
from fastapi import UploadFile
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session
from core.auth import RBACAccessType
from models.servicemodel import ServiceModel
from core.context_vars import context_set_response_code_message
import stripe

from repositories.base import (
    BaseRepository,
    CreateSchemaType,
    EntityType,
    FilterSchemaType,
)
from schemas.base import BaseGenericResponse
from schemas.serviceschema import (
    ServiceCreateSchema,
    ServiceFilterSchema,
    ServicePriceReadSchema,
    ServiceReadSchema,
    ServiceUpdateSchema,
)


class ServiceRepository(
    BaseRepository[ServiceModel, ServiceCreateSchema, ServiceUpdateSchema]
):
    def get_some(
        self, db: Session, skip: int, limit: int, filters: ServiceFilterSchema
    ) -> List[EntityType]:
        query = db.query(self.entity)

        filters_conditions = self.build_filters(
            self.entity, filters.__dict__ if filters else {}
        )
        query = query.filter(filters_conditions)
        total_count = query.count()

        entities = query.offset(skip).limit(limit).all()

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        result = []

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s not found / not found in the ",
                    status_code=404,
                )
            )
            return None
        elif len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No {self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                    count=0,
                )
            )
            return []
        else:
            for entity in entities:
                try:
                    stripe_product = stripe.Product.retrieve(
                        id=entity.stripe_product_id
                    )
                    stripe_price = stripe.Price.retrieve(id=entity.stripe_price_id)
                    result.append(
                        ServicePriceReadSchema(
                            id=entity.id,
                            active=stripe_product.active,
                            amount=stripe_price.unit_amount,
                            currency=stripe_price.currency,
                            created_at=datetime.fromtimestamp(stripe_product.created),
                            description=stripe_product.description,
                            features=stripe_product.features,
                            images=stripe_product.images,
                            name=stripe_product.name,
                            type=stripe_product.type,
                            unit_label=stripe_product.unit_label,
                            updated_at=datetime.fromtimestamp(stripe_product.updated),
                            recurring=entity.recurring,
                            url=stripe_product.url,
                        )
                    )
                except Exception as e:
                    context_set_response_code_message.set(
                        BaseGenericResponse(
                            error=True,
                            message=f"{e}",
                            status_code=400,
                        )
                    )
                    return None
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s found",
                    status_code=200,
                    count=len(result),
                )
            )
            return result

    def get(self, db: Session, filter: ServiceFilterSchema) -> EntityType | None:
        entity = db.query(self.entity).filter(self.entity.id == filter.id).first()
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

        try:
            stripe_product = stripe.Product.retrieve(id=entity.stripe_product_id)
            stripe_price = stripe.Price.retrieve(id=entity.stripe_price_id)
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} found",
                    status_code=200,
                )
            )
            return ServicePriceReadSchema(
                id=entity.id,
                active=stripe_product.active,
                amount=stripe_price.unit_amount,
                currency=stripe_price.currency,
                created_at=datetime.fromtimestamp(stripe_product.created),
                description=stripe_product.description,
                features=stripe_product.features,
                images=stripe_product.images,
                name=stripe_product.name,
                type=stripe_product.type,
                unit_label=stripe_product.unit_label,
                updated_at=datetime.fromtimestamp(stripe_product.updated),
                recurring=entity.recurring,
                url=stripe_product.url,
            )
        except Exception as e:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{e}",
                    status_code=400,
                )
            )
            return None

    def create(self, db: Session, *, obj_in: ServiceCreateSchema) -> EntityType | None:
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

        try:
            stripe_product = stripe.Product.create(
                name=obj_in.name, description=obj_in.description
            )

            # if obj_in.recurring:
            #     price_data['recurring'] = ''

            stripe_price = stripe.Price.create(
                unit_amount=int(obj_in.amount * 100),
                currency="usd",
                product=stripe_product.id,
            )

            new_service = ServiceModel(
                name=obj_in.name,
                description=obj_in.description,
                stripe_product_id=stripe_product.id,
                stripe_price_id=stripe_price.id,
                amount=obj_in.amount,
                recurring=obj_in.recurring,
            )

            db.add(new_service)
            db.commit()
            db.refresh(new_service)

            if new_service is not None:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=False,
                        message=f"{self.entity.get_resource_name(self.entity.__name__)} created successfully",
                        status_code=201,
                    )
                )

            return ServicePriceReadSchema(
                id=new_service.id,
                active=stripe_product.active,
                amount=stripe_price.unit_amount,
                currency=stripe_price.currency,
                created_at=datetime.fromtimestamp(stripe_product.created),
                description=stripe_product.description,
                features=stripe_product.features,
                images=stripe_product.images,
                name=stripe_product.name,
                type=stripe_product.type,
                unit_label=stripe_product.unit_label,
                updated_at=datetime.fromtimestamp(stripe_product.updated),
                recurring=new_service.recurring,
                url=stripe_product.url,
            )

        except Exception as e:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{e}",
                    status_code=400,
                )
            )
            return None

    def update(self, db: Session, obj_in: ServiceUpdateSchema):
        service = db.query(self.entity).filter_by(id=obj_in.filter.id).first()
        if not service:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=404,
                )
            )
            return None

        try:
            stripe.Product.modify(
                service.stripe_product_id,
                name=obj_in.update.name,
                description=obj_in.update.description,
            )
            service.name = obj_in.update.name
            service.description = obj_in.update.description
            db.commit()
            db.refresh(service)
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} updated successfully",
                    status_code=200,
                )
            )
            return service
        except Exception as e:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{e}",
                    status_code=400,
                )
            )
            return None

    def update_price(
        self, db: Session, obj_in: ServiceUpdateSchema
    ) -> EntityType | None:
        service = db.query(self.entity).filter_by(id=obj_in.filter.id).first()
        if not service:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=404,
                )
            )
            return None

        try:
            new_stripe_price = stripe.Price.create(
                unit_amount=int(obj_in.update.amount * 100),
                currency="usd",
                product=service.stripe_product_id,
            )
            stripe_product = stripe.Product.retrieve(id=service.stripe_product_id)
            service.stripe_price_id = new_stripe_price.id
            service.amount = new_stripe_price.unit_amount
            service.recurring = obj_in.update.recurring
            db.add(service)
            db.commit()
            db.refresh(service)
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} price updated successfully",
                    status_code=200,
                )
            )
            return ServicePriceReadSchema(
                id=service.id,
                active=stripe_product.active,
                amount=new_stripe_price.unit_amount,
                currency=new_stripe_price.currency,
                created_at=datetime.fromtimestamp(stripe_product.created),
                description=stripe_product.description,
                features=stripe_product.features,
                images=stripe_product.images,
                name=stripe_product.name,
                type=stripe_product.type,
                unit_label=stripe_product.unit_label,
                updated_at=datetime.fromtimestamp(stripe_product.updated),
                recurring=new_stripe_price.recurring,
                url=stripe_product.url,
            )
        except Exception as e:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{e}",
                    status_code=400,
                )
            )
            return None
