import json
from fastapi import HTTPException, Request
import stripe
from core.context_vars import context_set_response_code_message, context_actor_user_data
from typing import Any
from core.security import Settings
from models.assignagentmodel import AssignAgentModel
from models.batchreservemodel import BatchReserveModel
from models.batchtransfermodel import BatchTransferModel
from models.cvmodel import CVModel
from models.employeemodel import EmployeeModel
from models.invoicemodel import InvoiceModel
from models.processmodel import ProcessModel
from models.promotionmodel import PromotionModel
from models.reservemodel import ReserveModel
from models.servicemodel import ServiceModel
from sqlalchemy.orm import Session
from models.startedagentprocessmodel import StartedAgentProcessModel
from models.transfermodel import TransferModel
from models.transferrequestmodel import TransferRequestModel
from models.usermodel import UserModel
from repositories.promotion import PromotionRepository
from schemas.base import BaseGenericResponse
from schemas.checkoutschema import CheckoutCreateSchema, CheckoutTypeSchema
from schemas.promotionschema import PromotionCreateSchema, PromotionStatusSchema

settings = Settings()


class CheckoutRepository:
    def create_session(self, db: Session, obj_in: CheckoutCreateSchema) -> Any:
        service = db.query(ServiceModel).filter_by(id=obj_in.service_id).first()
        user = context_actor_user_data.get()
        customer = db.query(UserModel).filter_by(id=user.id).first()
        if not service:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="Service Not Found",
                    status_code=404,
                )
            )
            return None

        if not customer.stripe_customer_id:
            try:
                stripe_customer = stripe.Customer.create(
                    email=customer.email,
                    name=customer.first_name + " " + customer.last_name,
                )
                customer.stripe_customer_id = stripe_customer.id
                db.commit()
            except stripe.error.StripeError as e:
                context_set_response_code_message.set(
                    BaseGenericResponse(
                        error=True,
                        message=str(e),
                        status_code=400,
                    )
                )
                return

        metadata_json = json.dumps(obj_in.metadata)

        invoice = InvoiceModel(amount=service.amount, customer_id=user.id)
        db.add(invoice)
        db.commit()

        try:
            checkout_session = stripe.checkout.Session.create(
                payment_method_types=["card"],
                line_items=[
                    {
                        "price_data": {
                            "currency": "usd",
                            "unit_amount": int(service.amount * 100),
                            "product_data": {
                                "name": service.name,
                            },
                        },
                        "quantity": obj_in.quantity,
                    }
                ],
                mode="payment",
                success_url=obj_in.success_url,
                cancel_url=obj_in.cancel_url,
                customer=customer.stripe_customer_id,
                payment_intent_data={
                    "metadata": {
                        "generic_metadata": metadata_json,
                    }
                },
                metadata={
                    "generic_metadata": metadata_json,
                },
            )

            invoice.stripe_session_id = checkout_session.id
            db.commit()
            return {"url": checkout_session.url}
        except Exception as e:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message=str(e),
                    status_code=400,
                )
            )
            return

    async def webhook(self, db: Session, request: Request) -> Any:
        payload = await request.body()
        sig_header = request.headers.get("Stripe-Signature")
        event = None

        try:
            event = stripe.Webhook.construct_event(
                payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
            )
        except ValueError as e:
            raise HTTPException(status_code=400, detail="Invalid payload")
        except stripe.error.SignatureVerificationError as e:
            raise HTTPException(status_code=400, detail="Invalid signature")

        if event["type"] == "checkout.session.completed":
            session = event["data"]["object"]
            metadata_json = session.get("metadata", {}).get("generic_metadata", "{}")

            metadata_object = json.loads(metadata_json)
            activity_type = metadata_object.get("activity_type")
            invoice = (
                db.query(InvoiceModel).filter_by(stripe_session_id=session.id).first()
            )
            if invoice:
                if activity_type == CheckoutTypeSchema.TRANSFER_REQUEST:
                    batch_transfer_id = metadata_object.get("batch_transfer_id")
                    batch_transfer = (
                        db.query(BatchTransferModel)
                        .filter_by(id=int(batch_transfer_id))
                        .first()
                    )
                    transfer_request_ids = metadata_object.get("transfer_ids", [])
                    for transfer_request_id in transfer_request_ids:
                        transfer_request = (
                            db.query(TransferRequestModel)
                            .filter_by(id=int(transfer_request_id))
                            .first()
                        )
                        if transfer_request:
                            transfer_request.status = "paid"
                            employee = (
                                db.query(EmployeeModel)
                                .filter_by(user_id=transfer_request.user_id)
                                .first()
                            )

                            new_transfer = TransferModel(
                                user_id=transfer_request.user_id,
                                manager_id=batch_transfer.receiver_id,
                                previous_manager_id=employee.manager_id,
                            )
                            employee.manager_id = batch_transfer.receiver_id
                            db.add(new_transfer)
                            db.commit()
                            db.refresh(new_transfer)

                if activity_type == CheckoutTypeSchema.RESERVE_PROFILE:
                    reserve_ids = metadata_object.get("reserve_ids", [])
                    for reserve_id in reserve_ids:
                        reserve = (
                            db.query(ReserveModel).filter_by(id=int(reserve_id)).first()
                        )
                        if reserve:
                            reserve.status = "paid"
                            cv = db.query(CVModel).filter_by(id=reserve.cv_id).first()

                            new_process = ProcessModel(
                                user_id=cv.user_id, requester_id=reserve.reserver_id
                            )
                            db.add(new_process)
                            db.commit()
                            db.refresh(new_process)
                if activity_type == CheckoutTypeSchema.PROFILE_PROMOTION:
                    user_ids = metadata_object.get("user_ids", [])
                    package = metadata_object.get("package")
                    promotion_repo = PromotionRepository(PromotionModel)
                    new_promotions = PromotionCreateSchema(
                        package=package, user_ids=user_ids
                    )
                    promotion_repo.activate_promotion(db, obj_in=new_promotions)
                if activity_type == CheckoutTypeSchema.ACCEPT_EMPLOYEE_PROCESS:
                    assign_agent_id = metadata_object.get("assign_agent_id")
                    assign_agent = (
                        db.query(AssignAgentModel)
                        .filter_by(id=int(assign_agent_id))
                        .first()
                    )
                    if assign_agent:
                        assign_agent.status = "paid"

                    started_process = StartedAgentProcessModel(
                        user_id=assign_agent.user_id,
                        agent_id=assign_agent.agent_id,
                        assign_agent_id=int(assign_agent_id),
                    )
                    db.add(started_process)
                    db.commit()
                    db.refresh(started_process)

                invoice.status = "paid"
                db.commit()
                db.refresh(invoice)

        return {"status": "success"}
