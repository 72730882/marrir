import json
from faker import Faker
from locust import HttpUser, task, between

from schemas.cvschema import CVUpsertSchema
from routers.cv import cv_router_prefix


class PerformanceTests(HttpUser):
    wait_time = between(1, 3)
    fake = Faker()

    @task(1)
    def test_load_upsert_cv(self):
        sample = CVUpsertSchema(
            english_full_name=self.fake.english_full_name(),
            email=self.fake.email(),
        )
        headers = {"Accept": "application/json", "Content-Type": "application/json"}
        response = self.client.post(
            cv_router_prefix + "/", data=json.dumps(sample.__dict__), headers=headers
        )

        print(response.status_code)

        assert response.status_code == 201
