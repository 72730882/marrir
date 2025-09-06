import base64
import datetime
from io import BytesIO
import json
import os
import shutil
from typing import List, Optional
import uuid
from fastapi import HTTPException, UploadFile
from fastapi.responses import RedirectResponse
import psycopg2
from sqlalchemy.orm import Session
from models.paymentmodel import PaymentModel
from core.context_vars import context_set_response_code_message
from models.refundmodel import RefundModel
import stripe

from models.usermodel import UserModel
from repositories.base import (
    BaseRepository,
    CreateSchemaType,
    EntityType,
    FilterSchemaType,
)
from schemas.base import BaseGenericResponse
from schemas.paymentschema import (
    PaymentCreateSchema,
    PaymentFilterSchema,
    PaymentMethodDetails,
    PaymentStatusSchema,
    StripePaymentFilterSchema,
    StripePaymentReadSchema,
)
from utils.uploadfile import uploadFileToLocal

from core.security import settings


class PaymentRepository(
    BaseRepository[PaymentModel, PaymentCreateSchema, PaymentCreateSchema]
):
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

    async def get_stripe_payments(
        self,
        db: Session,
        filters: StripePaymentFilterSchema,
        # limit: int,
        # starting_after: Optional[str] = None,
        # ending_before: Optional[str] = None,
    ):
        # try:
        #     charges = stripe.Charge.list(
        #         customer=filter.stripe_customer_id,
        #         limit=limit,
        #         starting_after=starting_after,
        #         ending_before=ending_before,
        #     )
        #     return {
        #         "data": charges.data,
        #         "has_more": charges.has_more,
        #         "url": "/charges",  # Base URL for building next/previous links
        #         "limit": limit,
        #         "starting_after": (
        #             charges.data[-1].id if charges.data and charges.has_more else None
        #         ),
        #         "ending_before": charges.data[0].id if charges.data else None,
        #     }
        # except stripe.error.StripeError as e:
        #     return {"error": str(e)}
        print(f"Filters received: {filters}")  # Debugging user_id

        print("filteeeaar user id",filters.user_id)
        if filters and filters.user_id:
            users = db.query(UserModel).filter_by(id=filters.user_id).all()
        else:
            users = (
                db.query(UserModel)
                .filter(UserModel.stripe_customer_id.isnot(None))
                .all()
            )

        if not users:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="No users found!",
                    status_code=404,
                )
            )
            return

        print(users, "USERS")
        payments_data = [
            
        ]
        for user in users:
            try:
                if not user.stripe_customer_id:
                    continue
                print(user.stripe_customer_id, "STRIPE")
                payments = stripe.Charge.list(customer=user.stripe_customer_id)
                print(payments)
                print("*" * 70)
                for payment in payments.auto_paging_iter():
                    metadata = payment.metadata.get("generic_metadata", {})
                    
                    if isinstance(metadata, str):
                        try:
                            metadata = json.loads(metadata)
                        except json.JSONDecodeError:
                            metadata = {}
                    else:
                        metadata = metadata
                        
                    if filters:
                        if (filters.role and metadata.get("role") != filters.role) or (
                            filters.activity_type
                            and metadata.get("activity_type") != filters.activity_type
                        ):
                            continue
                    payments_data.append(
                        StripePaymentReadSchema(
                            id=payment.id,
                            amount=payment.amount,
                            currency=payment.currency,
                            description=payment.description,
                            created=payment.created,
                            status=payment.status,
                            paid=payment.paid,
                            refunded=payment.refunded,
                            receipt_url=payment.receipt_url,
                            payment_method_details=PaymentMethodDetails(
                                type=payment.payment_method_details.type,
                                card_brand=payment.payment_method_details.card.brand,
                                last_four_digits=payment.payment_method_details.card.last4,
                            ),
                        )
                    )
                    print(payments_data)
                    print("=" * 87)

            except stripe.error.StripeError as e:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=str(e),
                        status_code=400,
                    )
                )
                return

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=(
                    "Customer payments found!"
                    if payments_data
                    else "No payments found."
                ),
                status_code=200,
                count=len(payments_data),
            )
        )
        return payments_data

    async def make_payment(
        self,
        *,
        db: Session,
        file: UploadFile,
        amount: float,
        bank: str,
        transaction_id: str,
        transaction_date,
        user_profile_id: int,
    ) -> EntityType | None:
        new_payment = PaymentModel(
            amount=amount,
            bank=bank,
            transaction_id=transaction_id,
            transaction_date=transaction_date,
            user_profile_id=user_profile_id,
        )

        # upload to local folder. change to aws or gcs when possible
        new_payment.transaction_screenshot_path = uploadFileToLocal(file)
        db.add(new_payment)
        db.commit()
        db.refresh(new_payment)

        if new_payment is not None:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} created successfully",
                    status_code=201,
                )
            )

        return new_payment

    async def approve_payment(
        self,
        *,
        db: Session,
        filter: PaymentFilterSchema,
        status: PaymentStatusSchema,
    ) -> EntityType | None:
        payment = db.query(PaymentModel).filter_by(id=filter.id).first()

        if not payment:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message=f"{self.entity.get_resource_name(self.entity.__name__)} not found",
                    status_code=201,
                )
            )
            return None

        if payment.status != PaymentStatusSchema.PENDING:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=False,
                    message="Already approved payment!",
                    status_code=200,
                )
            )
            return None
            
        payment.status = status
        db.commit()
        db.refresh(payment)

        return payment
