import json
import unittest
from datetime import timedelta
from enum import unique, Enum

from fastapi import Depends
from fastapi.testclient import TestClient

from core.security import encode_user_access_token, encode_user_refresh_token
from main import app
from models import UserModel
from models.addressmodel import AddressModel
from models.db import build_request_context, get_db_session
from models.processmodel import ProcessModel
from repositories.process import ProcessRepository
from repositories.user import UserRepository
from routers.user import user_router_prefix
from routers.process import process_router_prefix
from schemas.processschema import ProcessFilterSchema, ProcessUpsertSchema
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


class ProcessTests(unittest.TestCase):
    def setUp(
        self,
        _=Depends(build_request_context),
    ):
        self.db_session = get_db_session()
        self.user_repo = UserRepository(entity=UserModel)
        self.process_repo = ProcessRepository(entity=ProcessModel)
        self.test_client = TestClient(app)
        self.user_router_prefix = user_router_prefix
        self.process_router_prefix = process_router_prefix

        # Create a process_creator for authentication
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

        self.process_input_upsert_data = ProcessUpsertSchema(
            email="login@user.com",
            coc="user_coc",
            insurance="user_insurance",
            injaz_slip="injaz_slip"
        )

        self.process_input_read_data = ProcessFilterSchema(email=self.process_input_upsert_data.email)

        self.process_input_read_progress_data = ProcessFilterSchema(
            email=self.process_input_upsert_data.email
        )

        self.process_input_delete_data = ProcessFilterSchema(
            email=self.process_input_upsert_data.email
        )

    # def tearDown(self):
    #     self.test_client.request(
    #         "DELETE",
    #         process_router_prefix + "/",
    #         json=ProcessFilterSchema(email=self.user_login.email).__dict__,
    #         headers={
    #             "x-access-token": self.user_token_data.get("access_token"),
    #             "x-refresh-token": self.user_token_data.get("refresh_token"),
    #         },
    #     )

    #     self.test_client.request(
    #         "DELETE",
    #         user_router_prefix + "/",
    #         json=UserFilterSchema(email=self.user_login.email).__dict__,
    #         headers={
    #             "x-access-token": self.user_token_data.get("access_token"),
    #             "x-refresh-token": self.user_token_data.get("refresh_token"),
    #         },
    #     )
    #     super().tearDown()

    def test_a_create_update_process(self):
        response = self.test_client.post(
            process_router_prefix + "/",
            json=self.process_input_upsert_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code in (200, 201)

    def test_b_read_process(self):
        response = self.test_client.post(
            process_router_prefix + "/single",
            json=self.process_input_read_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_c_view_process_progress(self):
        response = self.test_client.post(
            process_router_prefix + "/single",
            json=self.process_input_read_progress_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_d_delete_process(self):
        response = self.test_client.request(
            "DELETE",
            process_router_prefix + "/",
            json=self.process_input_delete_data.__dict__,
            headers={
                "x-access-token": self.user_token_data.get("access_token"),
                "x-refresh-token": self.user_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200
