import json
import random

from faker import Faker
from locust import HttpUser, task, between

from routers.user import user_router_prefix
from schemas.userschema import UserCreateSchema, UserRoleSchema


class PerformanceTests(HttpUser):
    wait_time = between(1, 3)
    fake = Faker()

    @staticmethod
    def random_role():
        roles = list(UserRoleSchema.__members__.keys())
        return roles[random.randint(a=0, b=len(roles) - 1)].lower()

    def fake_phone_number(self) -> str:
        return f'+2519{self.fake.msisdn()[5:]}'

    @task(1)
    def test_load_create_user(self):
        sample = UserCreateSchema(
            first_name=self.fake.first_name(),
            last_name=self.fake.last_name(),
            email=self.fake.email(),
            phone_number=self.fake_phone_number(),
            password=self.fake.password(),
            role=self.random_role()
        )
        headers = {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        }
        response = self.client.post(
            user_router_prefix + "/",
            data=json.dumps(sample.__dict__),
            headers=headers
        )

        print(response.status_code)

        assert response.status_code == 201
