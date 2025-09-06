include .env
export $(shell sed 's/=.*//' .env)

run:
	python main.py

perf_test:
	locust -f tests/test_performance_user.py

clean_docker:
	docker stop ps_db || true
	docker rm ps_db || true
	docker stop ps_app || true
	docker rm ps_app || true
	docker rmi ps_db || true
	docker rmi ps_app || true

connect_database:
	PGPASSWORD=$(DB_PASS) psql -U $(DB_USER) -h localhost -p $(DB_PORT) -d $(DB_NAME)
