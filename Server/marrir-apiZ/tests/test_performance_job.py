import json
import random

from faker import Faker
from locust import HttpUser, task, between

from routers.job import job_router_prefix
from schemas.jobschema import JobCreateSchema
from schemas.userschema import UserCreateSchema, UserRoleSchema


class PerformanceTests(HttpUser):
    wait_time = between(1, 3)
    fake = Faker()

    @task(1)
    def test_load_create_job(self):
        sample = JobCreateSchema(
            name=self.fake.name(),
            description=self.fake.description(),
            amount=self.fake.amount(),
            education_status=self.fake.education_status(),
            location=self.fake.location(),
            type=self.fake.type()
        )
        headers = {"Accept": "application/json", "Content-Type": "application/json"}
        response = self.client.post(
            job_router_prefix + "/", data=json.dumps(sample.__dict__), headers=headers
        )

        print(response.status_code)

        assert response.status_code == 201
