import unittest
from datetime import timedelta
from enum import unique, Enum

from fastapi import Depends
from fastapi.testclient import TestClient

from core.security import encode_user_access_token, encode_user_refresh_token
from main import app
from models import UserModel
from models.db import build_request_context, get_db_session
from models.ratingmodel import RatingModel
from repositories.rating import RatingRepository
from repositories.user import UserRepository
from routers.user import user_router_prefix
from routers.rating import rating_router_prefix
from schemas.ratingschema import (
    RatingCreateSchema,
    RatingFilterSchema,
    RatingTypeSchema,
    RatingUpdatePayload,
    RatingUpdateSchema,
    UserRatingSchema,
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


class RatingTests(unittest.TestCase):
    def setUp(
        self,
        _=Depends(build_request_context),
    ):
        self.db_session = get_db_session()
        self.user_repo = UserRepository(entity=UserModel)
        self.rating_repo = RatingRepository(entity=RatingModel)
        self.test_client = TestClient(app)
        self.user_router_prefix = user_router_prefix
        self.rating_router_prefix = rating_router_prefix

        # Create admin for authentication
        self.admin_login = UserCreateSchema(
            first_name="Login",
            last_name="User",
            email="login@user.com",
            phone_number="+251912000001",
            password="LoginUser@123",
            role=UserRoleSchema.ADMIN,
        )

        self.test_client.post(
            user_router_prefix + "/",
            json=self.admin_login.__dict__,
        )

        self.test_client.request(
            "PATCH",
            url=user_router_prefix + "/verify",
            json=UserFilterSchema(email=self.admin_login.email).__dict__,
        )

        # Obtain tokens for the authenticated user
        self.admin_data = UserLoginSchema(
            email=self.admin_login.email, password=self.admin_login.password
        )

        self.admin_token_data = (
            self.test_client.post(
                user_router_prefix + "/login", json=self.admin_data.__dict__
            )
            .json()
            .get("data")
        )

        # Create an employee for authentication
        self.employee_login = UserCreateSchema(
            first_name="Login2",
            last_name="User2",
            email="login2@user.com",
            phone_number="+251912000004",
            password="LoginUser@123",
            role=UserRoleSchema.EMPLOYEE,
        )
        self.test_client.post(
            user_router_prefix + "/",
            json=self.employee_login.__dict__,
        )

        self.test_client.request(
            "PATCH",
            url=user_router_prefix + "/verify",
            json=UserFilterSchema(email=self.employee_login.email).__dict__,
        )

        self.employee_data = UserLoginSchema(
            email=self.employee_login.email, password=self.employee_login.password
        )

        self.employee_token_data = (
            self.test_client.post(
                user_router_prefix + "/login", json=self.employee_data.__dict__
            )
            .json()
            .get("data")
        )

        # Prepare schema instances for rating-related tests
        self.rating_input_create_data = RatingCreateSchema(
            email=self.employee_login.email,
            rated_by=self.admin_login.email,
            value=4,
            description="admin comment",
        )

        self.rating_input_read_data = RatingFilterSchema(
            email=self.employee_login.email
        )

        self.rating_input_update_data = RatingUpdateSchema(
            filter=RatingFilterSchema(
                email=self.employee_login.email, rated_by=self.admin_login.email
            ),
            update=RatingUpdatePayload(value=5, description="Updated admin comment"),
        )

        self.rating_input_delete_data = RatingFilterSchema(
            email=self.employee_login.email, rated_by=self.admin_login.email
        )

    # def tearDown(self) -> None:
    #     return super().tearDown()

    def test_a_create_rating(self):
        response = self.test_client.post(
            rating_router_prefix + "/",
            json=self.rating_input_create_data.__dict__,
            headers={
                "x-access-token": self.admin_token_data.get("access_token"),
                "x-refresh-token": self.admin_token_data.get("refresh_token"),
            },
        )
        rating_already_exists_response = self.test_client.post(
            rating_router_prefix + "/",
            json=self.rating_input_create_data.__dict__,
            headers={
                "x-access-token": self.admin_token_data.get("access_token"),
                "x-refresh-token": self.admin_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 201
        assert rating_already_exists_response.status_code == 409

    def test_b_read_user_rating(self):
        response = self.test_client.request(
            "POST",
            rating_router_prefix + "/user",
            json=self.rating_input_read_data.__dict__,
            headers={
                "x-access-token": self.employee_token_data.get("access_token"),
                "x-refresh-token": self.employee_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_c_update_rating(self):
        response = self.test_client.put(
            rating_router_prefix + "/",
            json={
                "filter": self.rating_input_update_data.filter.__dict__,
                "update": self.rating_input_update_data.update.__dict__,
            },
            headers={
                "x-access-token": self.admin_token_data.get("access_token"),
                "x-refresh-token": self.admin_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200

    def test_d_delete_rating(self):
        response = self.test_client.request(
            "DELETE",
            rating_router_prefix + "/",
            json=self.rating_input_delete_data.__dict__,
            headers={
                "x-access-token": self.admin_token_data.get("access_token"),
                "x-refresh-token": self.admin_token_data.get("refresh_token"),
            },
        )
        assert response.status_code == 200
