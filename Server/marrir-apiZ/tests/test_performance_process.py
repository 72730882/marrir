import json
from faker import Faker
from locust import HttpUser, task, between

from schemas.processschema import ProcessUpsertSchema
from routers.process import process_router_prefix


class PerformanceTests(HttpUser):
    wait_time = between(1, 3)
    fake = Faker()

    @task(1)
    def test_load_upsert_process(self):
        sample = ProcessUpsertSchema(
            passport=self.fake.passport(),
            coc=self.fake.coc(),
            email=self.fake.email(),
        )
        headers = {"Accept": "application/json", "Content-Type": "application/json"}
        response = self.client.post(
            process_router_prefix + "/",
            data=json.dumps(sample.__dict__),
            headers=headers,
        )

        print(response.status_code)

        assert response.status_code in (200, 201)
