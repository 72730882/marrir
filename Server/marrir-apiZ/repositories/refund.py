import datetime
from typing import Any, Dict, Optional, Union, Generic, List
from fastapi.encoders import jsonable_encoder

from sqlalchemy import BinaryExpression
from sqlalchemy.orm import Session
from core.auth import RBACAccessType

from core.context_vars import context_set_response_code_message
from models.paymentmodel import PaymentModel
from models.refundmodel import RefundModel
from repositories.base import (
    BaseRepository,
    EntityType,
    FilterSchemaType,
)
from repositories.payment import PaymentRepository
from schemas.base import BaseGenericResponse
from schemas.enumschema import RefundStatusSchema
from schemas.paymentschema import PaymentFilterSchema
from schemas.refundschema import (
    RefundCreateSchema,
    RefundFilterSchema,
    RefundReviewSchema,
)


class RefundRepository(
    BaseRepository[RefundModel, RefundCreateSchema, RefundCreateSchema]
):
    def get_user_some(
        self, db: Session, skip: int, limit: int, filters: RefundFilterSchema
    ) -> List[EntityType]:
        entities = (
            db.query(PaymentModel)
            .filter(PaymentModel.user_profile_id == filters.user_profile_id)
            .all()
        )
        payment_ids = [entity.id for entity in entities]

        entities = (
            db.query(RefundModel)
            .filter(RefundModel.payment_id.in_(payment_ids))
            .offset(skip)
            .limit(limit)
            .all()
        )

        can_not_read = [
            self.is_allowed_or_is_owner(entity, RBACAccessType.read_multiple)
            for entity in entities
        ].__contains__(False)

        if can_not_read:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)}s not found / not found in the "
                    f"page specified",
                    status_code=404,
                )
            )
        elif len(entities) == 0:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"No {self.entity.get_resource_name(self.entity.__name__)}s found",
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

    def request_refund(
        self, *, db: Session, obj_in: RefundCreateSchema
    ) -> EntityType | None:
        payment = (
            db.query(PaymentModel).filter(PaymentModel.id == obj_in.payment_id).first()
        )

        if not payment:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{PaymentModel.get_resource_name(PaymentModel.__name__)} not found",
                    status_code=404,
                )
            )
            return None
        if payment.transaction_date < datetime.datetime.now() - datetime.timedelta(
            days=3
        ):
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="Payment is at least 3 days old. You can't ask for a refund",
                    status_code=400,
                )
            )
            return None
        else:
            refund = RefundModel(
                reason=obj_in.reason,
                payment_id=payment.id,
                status=RefundStatusSchema.PENDING,
            )
            db.add(refund)
            db.commit()
            db.refresh(refund)

            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} requested successfully. You will be notified ASAP!",
                    status_code=201,
                )
            )

            return refund

    def review_refund(self, db: Session, obj_in: RefundReviewSchema) -> EntityType:
        payment_repo = PaymentRepository(entity=PaymentModel)

        refund = self.get_by_id(db, obj_in.filter.refund_id)

        if not refund:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=404,
                )
            )
            return None
        if refund.status != RefundStatusSchema.PENDING:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} already reviewed",
                    status_code=400,
                )
            )
            return None
        if obj_in.update.status == RefundStatusSchema.SUCCESS:
            payment_repo.soft_delete(db, PaymentFilterSchema(id=refund.payment_id))
        refund.status = obj_in.update.status
        db.commit()
        db.refresh(refund)
        return refund
