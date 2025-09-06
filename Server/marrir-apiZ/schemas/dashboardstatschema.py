from typing import List, Optional
import uuid
from schemas.base import BaseProps


class DashboardFilterSchema(BaseProps):
    id: uuid.UUID


class StatSchema(BaseProps):
    value: int
    change: Optional[float] = None


class AdminDashboardUserRoleSchema(BaseProps):
    role_name: str
    user_count: int


class DashboardAdminStatSchema(BaseProps):
    accounts_registered: StatSchema
    online_payments: StatSchema
    local_payments: StatSchema
    role_counts: List[AdminDashboardUserRoleSchema] = []


class DashboardStatSchema(BaseProps):
    profile_view: StatSchema
    transfer_count: StatSchema
    job_count: StatSchema


class NonEmployeeDashboardStatSchema(BaseProps):
    profile_view: StatSchema
    employees_count: StatSchema
    male_employees_count: StatSchema
    female_employees_count: StatSchema
    transfers_count: StatSchema
    jobs_posted_count: StatSchema
