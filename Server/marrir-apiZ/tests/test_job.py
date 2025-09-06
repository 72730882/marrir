import unittest
from datetime import timedelta
from enum import unique, Enum

from fastapi import Depends
from fastapi.testclient import TestClient

from core.security import encode_user_access_token, encode_user_refresh_token
from main import app
from models import UserModel
from models.db import build_request_context, get_db_session
from models.jobapplicationmodel import JobApplicationModel
from models.jobmodel import JobModel
from repositories.job import JobRepository
from repositories.jobapplication import JobApplicationRepository
from repositories.user import UserRepository
from routers.user import user_router_prefix
from routers.job import job_router_prefix
from schemas.jobschema import (
    ApplyJobMultipleBaseSchema,
    ApplyJobSingleBaseSchema,
    JobCreateSchema,
    JobTypeSchema,
    JobUpdatePayload,
    JobUpdateSchema,
    JobsFilterSchema,
)
from schemas.userschema import (
    EducationStatusSchema,
    UserCreateSchema,
    UserFilterSchema,
    UserLoginSchema,
    UserRoleSchema,
)


@unique
class TokenCases(str, Enum):
    access_expired_refresh_not_expired = "access_expired_refresh_not_expired"
    access_expired_refresh_expired = "access_expired_refresh_expired"
    access_not_expired_refresh_expired = "access_not_expired_refresh_expired"
    access_not_expired_refresh_not_expired = "access_not_expired_refresh_not_expired"


class JobTests(unittest.TestCase):
    def setUp(
        self,
        _=Depends(build_request_context),
    ):
        self.db_session = get_db_session()
        self.user_repo = UserRepository(entity=UserModel)
        self.job_repo = JobRepository(entity=JobModel)
        self.job_application_repo = JobApplicationRepository(entity=JobApplicationModel)
        self.test_client = TestClient(app)
        self.user_router_prefix = user_router_prefix
        self.job_router_prefix = job_router_prefix

        # Create a job_creator for authentication
        self.user_login = UserCreateSchema(
            first_name="Login",
            last_name="User",
            email="login@user.com",
            phone_number="+251912000001",
            password="LoginUser@123",
            role=UserRoleSchema.SPONSOR,
        )

        self.test_client.post(
            user_router_prefix + "/",
            json=self.user_login.__dict__,
        )

        self.test_client.request(
            "PATCH",
            url=user_router_prefix + "/verify",
            json=UserFilterSchema(email=self.user_login.email).__dict__,
        )

        # Obtain tokens for the authenticated user
        self.login_data = UserLoginSchema(
            email=self.user_login.email, password=self.user_login.password
        )

        self.user_token_data = (
            self.test_client.post(
                user_router_prefix + "/login", json=self.login_data.__dict__
            )
            .json()
            .get("data")
        )

        # Create a job_applicant for authentication
        self.applicant_login = UserCreateSchema(
            first_name="Login2",
            last_name="User2",
            email="login2@user.com",
            phone_number="+251912000002",
            password="LoginUser@123",
            role=UserRoleSchema.EMPLOYEE,
        )
        self.test_client.post(
            user_router_prefix + "/",
            json=self.applicant_login.__dict__,
        )

        self.test_client.request(
            "PATCH",
            url=user_router_prefix + "/verify",
            json=UserFilterSchema(email=self.applicant_login.email).__dict__,
        )

        self.applicant_login_data = UserLoginSchema(
            email=self.applicant_login.email, password=self.applicant_login.password
        )

        self.applicant_token_data = (
            self.test_client.post(
                user_router_prefix + "/login", json=self.applicant_login_data.__dict__
            )
            .json()
            .get("data")
        )

        # Prepare schema instances for job-related tests
        self.job_input_create_data = JobCreateSchema(
            name="Job 1",
            description="job 1 description",
            type="contractual",
            amount=4,
            education_status=EducationStatusSchema.NO_EDUCATION,
            location="job 1 location",
        )

        self.job_input_read_data = JobsFilterSchema(
            name=self.job_input_create_data.name
        )

        self.job_input_update_data = JobUpdateSchema(
            filter=JobsFilterSchema(name=self.job_input_create_data.name),
            update=JobUpdatePayload(
                name="Job 1 updated",
                description="job 1 description updated",
                type="full_time",
                amount=5,
                education_status=EducationStatusSchema.PRIMARY_EDUCATION,
                location="job 1 location updated",
            ),
        )

        self.job_input_delete_data = JobsFilterSchema(
            name=self.job_input_update_data.update.name
        )

    # def tearDown(self) -> None:
    #     return super().tearDown()

    def test_a_create_job(self):
        response = self.test_client.post(
            job_router_prefix + "/",
            json=self.job_input_create_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        job_already_exists_response = self.test_client.post(
            job_router_prefix + "/",
            json=self.job_input_create_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 201
        assert job_already_exists_response.status_code == 409

    def test_b_read_jobs(self):
        response = self.test_client.request(
            "POST",
            job_router_prefix + "/paginated",
            json=self.job_input_read_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_c_read_job(self):
        response = self.test_client.post(
            job_router_prefix + "/single",
            json=self.job_input_read_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_d_job_application(self):
        job = (
            self.test_client.post(
                job_router_prefix + "/single",
                json=self.job_input_read_data.__dict__,
                headers={
                    "x-access-token": self.applicant_token_data.get("access_token"),
                    "x-refresh-token": self.applicant_token_data.get("refresh_token"),
                },
            )
            .json()
            .get("data")
        )
        applicant = ApplyJobMultipleBaseSchema(
            email=[self.applicant_login_data.email],
            job_id=job["id"],
        )
        response = self.test_client.post(
            job_router_prefix + "/apply",
            json=applicant.__dict__,
            headers={
                "x-access-token": self.applicant_token_data.get("access_token"),
                "x-refresh-token": self.applicant_token_data.get("refresh_token"),
            },
        )
        print(response.json(), "RESP")
        job_application_already_exists_response = self.test_client.post(
            job_router_prefix + "/apply",
            json=applicant.__dict__,
            headers={
                "x-access-token": self.applicant_token_data.get("access_token"),
                "x-refresh-token": self.applicant_token_data.get("refresh_token"),
            },
        )
        print(job_application_already_exists_response.json(), "RESP2")
        # assert response.status_code == 201
        assert job_application_already_exists_response.status_code == 409

    def test_e_delete_job_application(self):
        job = (
            self.test_client.post(
                job_router_prefix + "/single",
                # Convert the 'job_input_read_data' object to a dictionary and assign it to 'json'
                json=self.job_input_read_data.__dict__,
                headers={
                    "x-access-token": self.applicant_token_data.get("access_token"),
                    "x-refresh-token": self.applicant_token_data.get("refresh_token"),
                },
            )
            .json()
            .get("data")
        )

        response = self.test_client.request(
            "DELETE",
            job_router_prefix + "/apply/remove",
            json=ApplyJobSingleBaseSchema(
                email=self.login_data.email,
                job_id=job["id"],
            ).__dict__,
            headers={
                "x-access-token": self.applicant_token_data.get("access_token"),
                "x-refresh-token": self.applicant_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_f_update_job(self):
        response = self.test_client.patch(
            job_router_prefix + "/",
            json={
                "filter": self.job_input_update_data.filter.__dict__,
                "update": self.job_input_update_data.update.__dict__,
            },
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_g_soft_delete_job(self):
        response = self.test_client.request(
            "DELETE",
            job_router_prefix + "/close",
            json=self.job_input_delete_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_h_delete_job(self):
        response = self.test_client.request(
            "DELETE",
            job_router_prefix + "/",
            json=self.job_input_delete_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200
