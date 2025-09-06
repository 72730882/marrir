import json
import unittest
from datetime import timedelta
from enum import unique, Enum

from fastapi import Depends
from fastapi.testclient import TestClient

from main import app
from models import UserModel
from models.db import build_request_context, get_db_session
from models.transfermodel import TransferModel
from repositories.transfer import TransferRepository
from repositories.user import UserRepository
from routers.user import user_router_prefix
from routers.transfer import transfer_router_prefix
from schemas.transferschema import (
    TransferCreateSchema,
    TransferFilterSchema,
    TransferMultipleBaseSchema,
    TransferStatusSchema,
    TransferUpdatePayload,
    TransferUpdateSchema,
)
from schemas.userschema import (
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


class TransferTests(unittest.TestCase):
    def setUp(
        self,
        _=Depends(build_request_context),
    ):
        self.db_session = get_db_session()
        self.user_repo = UserRepository(entity=UserModel)
        self.transfer_repo = TransferRepository(entity=TransferModel)

        self.test_client = TestClient(app)
        self.user_router_prefix = user_router_prefix
        self.transfer_router_prefix = transfer_router_prefix

        # Create a transfer_creator for authentication
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

        # Create an agent for authentication
        self.agent_login = UserCreateSchema(
            first_name="Login2",
            last_name="User2",
            email="login2@user.com",
            phone_number="+251912000002",
            password="LoginUser@123",
            role=UserRoleSchema.AGENT,
        )
        self.test_client.post(
            user_router_prefix + "/",
            json=self.agent_login.__dict__,
        )

        self.test_client.request(
            "PATCH",
            url=user_router_prefix + "/verify",
            json=UserFilterSchema(email=self.agent_login.email).__dict__,
        )

        self.agent_login_data = UserLoginSchema(
            email=self.agent_login.email, password=self.agent_login.password
        )

        self.agent_token_data = (
            self.test_client.post(
                user_router_prefix + "/login", json=self.agent_login_data.__dict__
            )
            .json()
            .get("data")
        )

        # Prepare schema instances for transfer-related tests
        self.transfer_input_create_data = TransferMultipleBaseSchema(
            email=[self.user_login.email],
            manager_email=self.agent_login.email,
            status=TransferStatusSchema.PENDING,
        )

        self.transfer_input_read_data = TransferFilterSchema(
            email=self.login_data.email
        )

        self.transfer_accept_decline_data = TransferUpdateSchema(
            filter=TransferFilterSchema(email=self.login_data.email).__dict__,
            update=TransferUpdatePayload(status=TransferStatusSchema.ACCEPTED).__dict__,
        )

        print(self.transfer_accept_decline_data.filter.__dict__, "DFDFD")
        # {
        #     "filter": {"email": self.login_data.email},
        #     "update": {"status": TransferStatusSchema.ACCEPTED},
        # }

    # def tearDown(self) -> None:
    #     self.db_session.delete(TransferModel)
    #     self.db_session.delete(UserProfileModel)
    #     self.db_session.delete(JobApplicationModel)
    #     self.db_session.delete(JobModel)
    #     self.db_session.delete(TransferModel)
    #     self.db_session.delete(UserModel)
    #     return super().tearDown()

    def test_a_request_transfer(self):
        response = self.test_client.post(
            transfer_router_prefix + "/",
            json=self.transfer_input_create_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 201

    def test_b_read_transfers(self):
        response = self.test_client.request(
            "POST",
            transfer_router_prefix + "/paginated",
            json=self.transfer_input_read_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_c_accept_decline_transfer(self):
        response = self.test_client.patch(
            transfer_router_prefix + "/",
            json={
                "filter": self.transfer_accept_decline_data.filter.__dict__,
                "update": self.transfer_accept_decline_data.update.__dict__,
            },
            headers={
                "x-access-token": self.agent_token_data.get("access_token"),
                "x-refresh-token": self.agent_token_data.get("refresh_token"),
            },
        )
        print(response.json(), "Hello")
        assert response.status_code == 200
