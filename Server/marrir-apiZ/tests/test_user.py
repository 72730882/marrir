import unittest
from datetime import timedelta
from enum import unique, Enum

from fastapi import Depends
from fastapi.testclient import TestClient

from core.security import encode_user_access_token, encode_user_refresh_token
from main import app
from models import UserModel
from models.db import build_request_context, get_db_session
from repositories.user import UserRepository
from routers.user import user_router_prefix
from schemas.userschema import (UserCreateSchema, UserRoleSchema, UsersFilterSchema,
                                UserFilterSchema, UserUpdateSchema, \
                                UserLoginSchema, UserUpdatePayload, UserTokenSchema)


@unique
class TokenCases(str, Enum):
    access_expired_refresh_not_expired = "access_expired_refresh_not_expired"
    access_expired_refresh_expired = "access_expired_refresh_expired"
    access_not_expired_refresh_expired = "access_not_expired_refresh_expired"
    access_not_expired_refresh_not_expired = "access_not_expired_refresh_not_expired"


class UserTests(unittest.TestCase):
    def setUp(
            self,
            _=Depends(build_request_context),
    ):
        self.db_session = get_db_session()
        self.user_repo = UserRepository(entity=UserModel)
        self.test_client = TestClient(app)
        self.user_router_prefix = user_router_prefix

        # create login user
        self.user_login = UserCreateSchema(
            first_name='Login',
            last_name='User',
            email='login@user.com',
            phone_number='+251912000001',
            password='LoginUser@123',
            role=UserRoleSchema.ADMIN
        )
        self.test_client.post(
            user_router_prefix + '/',
            json=self.user_login.__dict__,
        )
        self.test_client.request(
            'PATCH',
            url=user_router_prefix + '/verify',
            json=UserFilterSchema(
                email=self.user_login.email
            ).__dict__
        )

        # get token from login
        self.login_data = UserLoginSchema(
            email=self.user_login.email,
            password=self.user_login.password
        )
        self.user_token_data = self.test_client.post(
            user_router_prefix + '/login',
            json=self.login_data.__dict__
        ).json().get('data')

        # schema instances for tests
        self.user_input_create_data = UserCreateSchema(
            first_name='Test',
            last_name='Case',
            email='test@case.com',
            phone_number='+251911000001',
            password='TestCase@123',
            role=UserRoleSchema.ADMIN
        )

        self.users_input_read_data = UsersFilterSchema(
            first_name=self.user_input_create_data.first_name
        )
        self.user_input_read_data = UserFilterSchema(
            email=self.user_input_create_data.email
        )
        self.user_input_update_data = UserUpdateSchema(
            filter=UserFilterSchema(
                email=self.user_input_create_data.email
            ),
            update=UserUpdatePayload(
                first_name='Test Updated',
                last_name='Case Updated',
                email='test_updated@case.com',
                phone_number='+251911000002',
                password='TestCaseUpdated@123',
                role=UserRoleSchema.EMPLOYEE
            )
        )
        self.user_input_delete_data = UserFilterSchema(
            email=self.user_input_update_data.update.email
        )

    def tearDown(self):
        self.test_client.request(
            'DELETE',
            user_router_prefix + '/',
            json=UserFilterSchema(
                email=self.user_login.email
            ).__dict__,
            headers={
                'x-access-token': self.user_token_data.get('access_token'),
                'x-refresh-token': self.user_token_data.get('refresh_token')
            }
        )
        super().tearDown()

    def test_a_create_user(self):
        response = self.test_client.post(
            user_router_prefix + '/',
            json=self.user_input_create_data.__dict__,
        )
        user_already_exists_response = self.test_client.post(
            user_router_prefix + '/',
            json=self.user_input_create_data.__dict__,
        )
        assert response.status_code == 201
        assert user_already_exists_response.status_code == 409

    def test_b_read_users(self):
        response = self.test_client.request(
            'POST',
            user_router_prefix + '/paginated',
            json=self.users_input_read_data.__dict__,
            headers={
                'x-access-token': self.user_token_data.get('access_token'),
                'x-refresh-token': self.user_token_data.get('refresh_token')
            }
        )
        assert response.status_code == 200

    def test_c_read_user(self):
        response = self.test_client.post(
            user_router_prefix + '/single',
            json=self.user_input_read_data.__dict__,
            headers={
                'x-access-token': self.user_token_data.get('access_token'),
                'x-refresh-token': self.user_token_data.get('refresh_token')
            }
        )
        assert response.status_code == 200

    def test_d_update_user(self):
        response = self.test_client.put(
            user_router_prefix + '/',
            json={
                "filter": self.user_input_update_data.filter.__dict__,
                "update": self.user_input_update_data.update.__dict__
            },
            headers={
                'x-access-token': self.user_token_data.get('access_token'),
                'x-refresh-token': self.user_token_data.get('refresh_token')
            }
        )
        assert response.status_code == 200

    def test_e_soft_delete_user(self):
        response = self.test_client.request(
            'DELETE',
            user_router_prefix + '/suspend',
            json=self.user_input_delete_data.__dict__,
            headers={
                'x-access-token': self.user_token_data.get('access_token'),
                'x-refresh-token': self.user_token_data.get('refresh_token')
            }
        )
        assert response.status_code == 200

    def test_f_delete_user(self):
        response = self.test_client.request(
            'DELETE',
            user_router_prefix + '/',
            json=self.user_input_delete_data.__dict__,
            headers={
                'x-access-token': self.user_token_data.get('access_token'),
                'x-refresh-token': self.user_token_data.get('refresh_token')
            }
        )
        assert response.status_code == 200

    def test_g_refresh_token_user(self):
        token_data = UserTokenSchema(
            email='kerod@gmail.com',
            phone_number='+251929033293',
            role='admin'
        )

        match TokenCases:
            case TokenCases.access_expired_refresh_not_expired:
                expired_access_token = encode_user_access_token(
                    subject=token_data,
                    expires_delta=timedelta(days=-1)
                )
                refresh_token = encode_user_refresh_token(
                    subject=token_data,
                    expires_delta=timedelta(days=30)
                )
                refreshed_token_data = self.test_client.get(
                    user_router_prefix + '/refresh',
                    headers={
                        'x-access-token': expired_access_token,
                        'x-refresh-token': refresh_token
                    }
                )
                assert refreshed_token_data.status_code == 200
                assert refreshed_token_data.headers.get('x-access-token') is not None
                assert refreshed_token_data.headers.get('x-refresh-token') is not None
            case TokenCases.access_expired_refresh_expired:
                expired_access_token = encode_user_access_token(
                    subject=token_data,
                    expires_delta=timedelta(days=-1)
                )
                refresh_token = encode_user_refresh_token(
                    subject=token_data,
                    expires_delta=timedelta(days=-1)
                )
                refreshed_token_data = self.test_client.get(
                    user_router_prefix + '/refresh',
                    headers={
                        'x-access-token': expired_access_token,
                        'x-refresh-token': refresh_token
                    }
                )
                assert refreshed_token_data.status_code == 401
                assert refreshed_token_data.headers.get('x-access-token') is None
                assert refreshed_token_data.headers.get('x-refresh-token') is None
            case TokenCases.access_not_expired_refresh_not_expired:
                expired_access_token = encode_user_access_token(
                    subject=token_data,
                    expires_delta=timedelta(days=7)
                )
                refresh_token = encode_user_refresh_token(
                    subject=token_data,
                    expires_delta=timedelta(days=30)
                )
                refreshed_token_data = self.test_client.get(
                    user_router_prefix + '/refresh',
                    headers={
                        'x-access-token': expired_access_token,
                        'x-refresh-token': refresh_token
                    }
                )
                assert refreshed_token_data.status_code == 400
                assert refreshed_token_data.headers.get('x-access-token') is None
                assert refreshed_token_data.headers.get('x-refresh-token') is None
            case TokenCases.access_not_expired_refresh_expired:
                expired_access_token = encode_user_access_token(
                    subject=token_data,
                    expires_delta=timedelta(days=7)
                )
                refresh_token = encode_user_refresh_token(
                    subject=token_data,
                    expires_delta=timedelta(days=-1)
                )
                refreshed_token_data = self.test_client.get(
                    user_router_prefix + '/refresh',
                    headers={
                        'x-access-token': expired_access_token,
                        'x-refresh-token': refresh_token
                    }
                )
                assert refreshed_token_data.status_code == 400
                assert refreshed_token_data.headers.get('x-access-token') is None
                assert refreshed_token_data.headers.get('x-refresh-token') is None
