from typing import List, Optional
from sqlalchemy import extract, func
from core.context_vars import context_set_response_code_message, context_actor_user_data
from sqlalchemy.orm import Session
from models.cvmodel import CVModel
from models.employeemodel import EmployeeModel
from models.invoicemodel import InvoiceModel
from models.jobapplicationmodel import JobApplicationModel
from models.jobmodel import JobModel
from models.paymentmodel import PaymentModel
from models.profileviewmodel import ProfileViewModel
from models.reservemodel import ReserveModel
from models.transfermodel import TransferModel
from models.usermodel import UserModel
from repositories.base import EntityType
from schemas.base import BaseGenericResponse
from schemas.dashboardstatschema import (
    AdminDashboardUserRoleSchema,
    DashboardAdminStatSchema,
    DashboardFilterSchema,
    DashboardStatSchema,
    NonEmployeeDashboardStatSchema,
)
from schemas.enumschema import SexSchema
from schemas.userschema import UserFilterSchema, UserRoleSchema
from utils.aggregate_period_stat import get_aggregated_stats


class DashboardRepository:
    def get_dashboard_data(
        self, db: Session, period: str, filters: Optional[DashboardFilterSchema]
    ) -> EntityType | None:
        profile_views = get_aggregated_stats(
            db=db,
            date_column=ProfileViewModel.created_at,
            filters=[ProfileViewModel.user_id == filters.id],
            period=period,
        )

        transfer_count = get_aggregated_stats(
            db=db,
            date_column=TransferModel.created_at,
            filters=[TransferModel.user_id == filters.id],
            period=period,
        )

        job_count = get_aggregated_stats(
            db=db,
            date_column=JobApplicationModel.created_at,
            filters=[JobApplicationModel.user_id == filters.id],
            period=period,
        )

        return DashboardStatSchema(
            profile_view=profile_views,
            transfer_count=transfer_count,
            job_count=job_count,
        )

    def get_non_employee_dashboard_data(
        self, db: Session, period: str, filters: Optional[DashboardFilterSchema]
    ):
        profile_views = get_aggregated_stats(
            db=db,
            date_column=ProfileViewModel.created_at,
            filters=[ProfileViewModel.profile_viewer_id == filters.id],
            period=period,
        )

        employees_count = get_aggregated_stats(
            db=db,
            date_column=EmployeeModel.created_at,
            filters=[EmployeeModel.manager_id == filters.id],
            period=period,
        )

        male_employees_count = get_aggregated_stats(
            db=db,
            date_column=CVModel.created_at,
            filters=[
                CVModel.sex == SexSchema.MALE,
                EmployeeModel.manager_id == filters.id,
            ],
            join_conditions=[(EmployeeModel, EmployeeModel.user_id == CVModel.user_id)],
            period=period,
        )

        female_employees_count = get_aggregated_stats(
            db=db,
            date_column=CVModel.created_at,
            filters=[
                CVModel.sex == SexSchema.FEMALE,
                EmployeeModel.manager_id == filters.id,
            ],
            join_conditions=[(EmployeeModel, EmployeeModel.user_id == CVModel.user_id)],
            period=period,
        )

        transfers_count = get_aggregated_stats(
            db=db,
            date_column=TransferModel.created_at,
            filters=[TransferModel.manager_id == filters.id],
            period=period,
        )

        jobs_posted_count = get_aggregated_stats(
            db=db,
            date_column=JobModel.created_at,
            filters=[JobModel.posted_by == filters.id],
            period=period,
        )

        return NonEmployeeDashboardStatSchema(
            profile_view=profile_views,
            employees_count=employees_count,
            male_employees_count=male_employees_count,
            female_employees_count=female_employees_count,
            transfers_count=transfers_count,
            jobs_posted_count=jobs_posted_count,
        )

    def get_admin_dashboard_data(self, db: Session, period: str) -> EntityType | None:
        role = context_actor_user_data.get().role
        if not role == UserRoleSchema.ADMIN:
            context_set_response_code_message.set(
                BaseGenericResponse(
                    error=True,
                    message="Unauthorized",
                    status_code=401,
                )
            )

        accounts_registered = get_aggregated_stats(
            db=db, date_column=UserModel.created_at, period=period
        )
        online_payments = get_aggregated_stats(
            db=db,
            date_column=InvoiceModel.created_at,
            period=period,
        )
        local_payments = get_aggregated_stats(
            db=db,
            date_column=PaymentModel.created_at,
            period=period,
        )

        role_counts = (
            db.query(UserModel.role, func.count(UserModel.role))
            .group_by(UserModel.role)
            .all()
        )

        role_count: List[AdminDashboardUserRoleSchema] = []
        for role, count in role_counts:
            role_count.append(
                AdminDashboardUserRoleSchema(role_name=role, user_count=count)
            )

        return DashboardAdminStatSchema(
            accounts_registered=accounts_registered,
            online_payments=online_payments,
            local_payments=local_payments,
            role_counts=role_count,
        )
