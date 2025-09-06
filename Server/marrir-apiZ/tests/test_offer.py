import json
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
from models.offermodel import OfferModel
from models.transfermodel import TransferModel
from models.userprofilemodel import UserProfileModel
from repositories.job import JobRepository
from repositories.jobapplication import JobApplicationRepository
from repositories.offer import OfferRepository
from repositories.user import UserRepository
from routers.user import user_router_prefix
from routers.job import job_router_prefix
from routers.offer import offer_router_prefix
from schemas.jobschema import (
    ApplyJobMultipleBaseSchema,
    ApplyJobSingleBaseSchema,
    JobCreateSchema,
    JobsFilterSchema,
)
from schemas.offerschema import (
    OfferCreateSchema,
    OfferFilterSchema,
    OfferTypeSchema,
    OfferUpdatePayload,
    OfferUpdateSchema,
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


class OfferTests(unittest.TestCase):
    def setUp(
        self,
        _=Depends(build_request_context),
    ):
        self.db_session = get_db_session()
        self.user_repo = UserRepository(entity=UserModel)
        self.offer_repo = OfferRepository(entity=OfferModel)
        self.job_repo = JobRepository(entity=JobModel)

        self.job_application_repo = JobApplicationRepository(entity=JobApplicationModel)
        self.test_client = TestClient(app)
        self.user_router_prefix = user_router_prefix
        self.offer_router_prefix = offer_router_prefix
        self.job_router_prefix = job_router_prefix

        # Create a offer_creator for authentication
        self.user_login = UserCreateSchema(
            first_name="Login",
            last_name="User",
            email="login@user.com",
            phone_number="+251912000001",
            password="LoginUser@123",
            role=UserRoleSchema.EMPLOYEE,
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

        # Create a sponsor for authentication
        self.sponsor_login = UserCreateSchema(
            first_name="Login2",
            last_name="User2",
            email="login2@user.com",
            phone_number="+251912000002",
            password="LoginUser@123",
            role=UserRoleSchema.SPONSOR,
        )
        self.test_client.post(
            user_router_prefix + "/",
            json=self.sponsor_login.__dict__,
        )

        self.test_client.request(
            "PATCH",
            url=user_router_prefix + "/verify",
            json=UserFilterSchema(email=self.sponsor_login.email).__dict__,
        )

        self.sponsor_login_data = UserLoginSchema(
            email=self.sponsor_login.email, password=self.sponsor_login.password
        )

        self.sponsor_token_data = (
            self.test_client.post(
                user_router_prefix + "/login", json=self.sponsor_login_data.__dict__
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

        self.test_client.post(
            job_router_prefix + "/",
            json=self.job_input_create_data.__dict__,
            headers={
                "x-access-token": self.sponsor_token_data.get("access_token"),
                "x-refresh-token": self.sponsor_token_data.get("refresh_token"),
            },
        )

        self.job = (
            self.test_client.post(
                job_router_prefix + "/single",
                json=self.job_input_read_data.__dict__,
                headers={
                    "x-access-token": self.sponsor_token_data.get("access_token"),
                    "x-refresh-token": self.sponsor_token_data.get("refresh_token"),
                },
            )
            .json()
            .get("data")
        )

        applicant = ApplyJobMultipleBaseSchema(
            email=[self.login_data.email],
            job_id=self.job["id"],
        )

        self.test_client.post(
            job_router_prefix + "/apply",
            json=applicant.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )

        # Prepare schema instances for offer-related tests
        self.offer_input_create_data = OfferCreateSchema(
            receiver_email=self.login_data.email,
            sponsor_email=self.sponsor_login.email,
            job_id=self.job["id"],
            detail="offer 1 detail",
            offer_status=OfferTypeSchema.PENDING,
        )

        self.offer_input_read_data = OfferFilterSchema(
            receiver_email=self.login_data.email,
            job_id=self.job["id"],
        )

    # def tearDown(self) -> None:
    #     self.db_session.delete(TransferModel)
    #     self.db_session.delete(UserProfileModel)
    #     self.db_session.delete(JobApplicationModel)
    #     self.db_session.delete(JobModel)
    #     self.db_session.delete(OfferModel)
    #     self.db_session.delete(UserModel)
    #     return super().tearDown()

    def test_a_make_offer(self):
        response = self.test_client.post(
            offer_router_prefix + "/",
            json=self.offer_input_create_data.__dict__,
            headers={
                "x-access-token": self.sponsor_token_data.get("access_token"),
                "x-refresh-token": self.sponsor_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 201

    def test_b_read_offers(self):
        response = self.test_client.request(
            "POST",
            offer_router_prefix + "/paginated",
            json=self.offer_input_read_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_c_read_offer(self):
        response = self.test_client.post(
            offer_router_prefix + "/single",
            json=self.offer_input_read_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_d_accept_decline_offer(self):
        offer = (
            self.test_client.post(
                offer_router_prefix + "/single",
                json=self.offer_input_read_data.__dict__,
                headers={
                    "x-access-token": self.user_token_data.get("access_token"),
                    "x-refresh-token": self.user_token_data.get("refresh_token"),
                },
            )
            .json()
            .get("data")
        )

        offer_input_update_data = {
            "filter": {
                "id": offer["id"],
            },
            "update": {
                "offer_status": OfferTypeSchema.ACCEPTED,
            },
        }
        response = self.test_client.patch(
            offer_router_prefix + "/",
            json=offer_input_update_data,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_e_rescind_offer(self):
        offer = (
            self.test_client.post(
                offer_router_prefix + "/single",
                json=self.offer_input_read_data.__dict__,
                headers={
                    "x-access-token": self.sponsor_token_data.get("access_token"),
                    "x-refresh-token": self.sponsor_token_data.get("refresh_token"),
                },
            )
            .json()
            .get("data")
        )

        offer_filter_data = OfferFilterSchema(
            id=offer["id"],
        )

        response = self.test_client.request(
            "DELETE",
            offer_router_prefix + "/",
            json=offer_filter_data.__dict__,
            headers={
                "x-access-token": self.sponsor_token_data.get("access_token"),
                "x-refresh-token": self.sponsor_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200
