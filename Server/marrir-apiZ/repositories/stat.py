from http.client import HTTPException
from core.context_vars import context_set_response_code_message, context_actor_user_data
from typing import Any, Dict, Optional
from sqlalchemy.orm import Session
from models.assignagentmodel import AssignAgentModel
from models.batchreservemodel import BatchReserveModel
from models.batchtransfermodel import BatchTransferModel
from models.cvmodel import CVModel
from models.employeemodel import EmployeeModel
from models.jobapplicationmodel import JobApplicationModel
from models.jobmodel import JobModel
from models.paymentmodel import PaymentModel
from models.processmodel import ProcessModel
from models.profileviewmodel import ProfileViewModel
from models.promotionmodel import PromotionModel
from models.reservemodel import ReserveModel
from models.startedagentprocessmodel import StartedAgentProcessModel
from models.transfermodel import TransferModel
from models.usermodel import UserModel
from repositories.base import EntityType
from schemas.base import BaseGenericResponse
from schemas.enumschema import UserRoleSchema
from utils.aggregate_period_stat import get_aggregated_stats


class StatRepository:
    def get_stats(
        self,
        db: Session,
        stat_type: str,
        period: str,
        filters: Optional[Dict[str, Any]] = None,
    ) -> EntityType | None:
        model = None
        if stat_type == "total_users":
            model = UserModel
            date_column = UserModel.created_at
        elif stat_type == "total_employees":
            model = EmployeeModel
            date_column = EmployeeModel.created_at
        elif stat_type == "total_transfers":
            model = TransferModel
            date_column = TransferModel.created_at
        elif stat_type == "total_transfers_requests":
            model = BatchTransferModel
            date_column = BatchTransferModel.created_at
        elif stat_type == "total_reserves":
            model = ReserveModel
            date_column = ReserveModel.created_at
        elif stat_type == "total_reserves_sents":
            model = BatchReserveModel
            date_column = BatchReserveModel.created_at
        elif stat_type == "total_reserves_received":
            return self.get_total_reserves_received(db, period)
        elif stat_type == "total_promotions":
            model = PromotionModel
            date_column = PromotionModel.created_at
        elif stat_type == "total_jobs":
            model = JobModel
            date_column = JobModel.created_at
        elif stat_type == "total_job_applications":
            model = JobApplicationModel
            date_column = JobApplicationModel.created_at
        elif stat_type == "total_payments":
            model = PaymentModel
            date_column = PaymentModel.created_at
        elif stat_type == "total_processes":
            model = ProcessModel
            date_column = ProcessModel.created_at
        elif stat_type == "total_processes_received":
            model = AssignAgentModel
            date_column = AssignAgentModel.created_at
        elif stat_type == "total_processes_startable":
            model = StartedAgentProcessModel
            date_column = StartedAgentProcessModel.created_at
        else:
            raise HTTPException(400, "Invalid stat type")

        query_filters = []
        if filters:
            for key, value in filters.items():
                query_filters.append(getattr(model, key) == value)

        total_count = get_aggregated_stats(
            db=db, date_column=date_column, filters=query_filters, period=period
        )

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"Stat found",
                status_code=200,
            )
        )

        return total_count

    def get_total_reserves_received(
        self,
        db: Session,
        period: str,
    ):
        user = context_actor_user_data.get()
        if user.role == UserRoleSchema.EMPLOYEE:
            reserves_received_count = get_aggregated_stats(
                db=db,
                date_column=ReserveModel.created_at,
                filters=[
                    CVModel.user_id == user.id,
                ],
                join_conditions=[(CVModel, ReserveModel.cv_id == CVModel.id)],
                period=period,
            )
        else:
            employee_ids = (
                db.query(EmployeeModel.user_id).filter_by(manager_id=user.id).all()
            )
            employee_ids = [id[0] for id in employee_ids]
            reserves_received_count = get_aggregated_stats(
                db=db,
                date_column=BatchReserveModel.created_at,
                filters=[
                    CVModel.user_id.in_(employee_ids),
                ],
                join_conditions=[
                    (ReserveModel, ReserveModel.batch_id == BatchReserveModel.id),
                    (CVModel, ReserveModel.cv_id == CVModel.id),
                ],
                period=period,
            )

        context_set_response_code_message.set(
            BaseGenericResponse(
                error=False,
                message=f"Stat found",
                status_code=200,
            )
        )

        return reserves_received_count
