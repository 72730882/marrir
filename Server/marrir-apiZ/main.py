import json
from fastapi.staticfiles import StaticFiles
import stripe

import uvicorn
from fastapi import FastAPI, Request
from sqlalchemy.exc import ProgrammingError
from starlette.responses import JSONResponse
from core.context_vars import context_log_meta, context_set_db_session_rollback
from core.security import Settings
from logger import logger
from models.db import SessionLocal
from models.migrate import init_db
from routers.user import user_router
from routers.notification import notification_router
from routers.job import job_router
from routers.cv import cv_router
from routers.process import process_router
from routers.payment import payment_router
from routers.occupation import occupation_router
from routers.refund import refund_router
from routers.promotion import promotion_router
from routers.reserve import reserve_router
from routers.offer import offer_router
from routers.transfer import transfer_router
from routers.dashboard import dashboard_router
from routers.stat import stat_router
from routers.rating import rating_router
from routers.companyinfo import company_info_router
from routers.employeestatus import employee_status_router
from routers.service import service_router
from routers.checkout import checkout_router
from routers.assignagent import assign_agent_router
from seed import seed_promotion_package
from utils.exceptions import AppException
from cron_jobs import inactive_expired_promotion, scheduler, delete_declined_and_cancelled_reserves

tags_metadata = [
    {"name": "user", "description": "user routes"},
    {"name": "notification", "description": "notification routes"},
    {"name": "job", "description": "job routes"},
    {"name": "cv", "description": "cv routes"},
    {"name": "process", "description": "process routes"},
    {"name": "payment", "description": "payment routes"},
    {"name": "reserve", "description": "reserve routes"},
    {"name": "promotion", "description": "promotion routes"},
    {"name": "refund", "description": "refund routes"},
    {"name": "occupation", "description": "occupation routes"},
    {"name": "offer", "description": "offer routes"},
    {"name": "transfer", "description": "transfer routes"},
    {"name": "dashboard", "description": "dashboard routes"},
    {"name": "stat", "description": "stat routes"},
    {"name": "rating", "description": "rating routes"},
    {"name": "companyinfo", "description": "company info routes"},
    {"name": "service", "description": "service routes"},
    {"name": "checkout", "description": "checkout routes"},
    {"name": "employeestatus", "description": "employee status routes"},
    {"name": "assignagent", "description": "assign agent routes"},
]

app = FastAPI(
    title="marrir api",
    description="Marrir API",
    version="1.0",
    swagger_ui_parameters={"defaultModelsExpandDepth": -1},
    openapi_tags=tags_metadata,
)

origins = ["*"]
settings = Settings()

stripe.api_key = settings.STRIPE_SECRET_KEY


@app.middleware("http")
async def cors_middleware(request: Request, call_next):
    response = await call_next(request)
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Credentials"] = "true"
    response.headers["Access-Control-Allow-Methods"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "*"
    return response


@app.api_route("/{path_name:path}", methods=["OPTIONS"])
async def check_options(request: Request):
    pass


@app.exception_handler(ProgrammingError)
def sql_exception_handler(request: Request, exc):
    context_set_db_session_rollback.set(True)
    logger.error(
        extra=context_log_meta.get(),
        msg=f"sql exception occurred; error: {str(exc.args)} statement : {exc.statement}",
    )
    return JSONResponse(
        status_code=500,
        content={
            "message": f"Data Source Error / Internal Server Occurred",
            "error": True,
            "status_code": 500,
        },
    )


@app.exception_handler(AppException)
async def application_exception_handler(request, exc):
    context_set_db_session_rollback.set(True)
    logger.error(
        extra=context_log_meta.get(),
        msg=f"application exception occurred error: {json.loads(str(exc))}",
    )
    return JSONResponse(
        status_code=exc.status_code,
        content={"message": exc.message, "error": True, "status_code": exc.status_code},
    )


@app.get("/set-session")
async def set_session(request: Request):
    request.session["key"] = "value"
    return {"message": "Session data set"}


@app.get("/get-session")
async def get_session(request: Request):
    value = request.session.get("key", "Not set")
    return {"session_value": value}

async def con_job_event():
    logger.info("initializing database")
    init_db()
    db = SessionLocal()
    if db:
        scheduler.add_job(delete_declined_and_cancelled_reserves, 'interval', hours=24, args=[db])
        scheduler.add_job(inactive_expired_promotion, 'interval', hours=24, args=[db])
        seed_promotion_package(db)
    else:
        print("Failed to get a valid database session.")

app.add_event_handler("startup", con_job_event)

app.mount("/static", StaticFiles(directory="static"), name="static")
# ✅ Mount the static directory here
app.mount("/uploaded_terms", StaticFiles(directory="uploaded_terms"), name="uploaded_terms")

app.include_router(user_router, tags=["user"])
app.include_router(notification_router, tags=["notification"])
app.include_router(job_router, tags=["job"])
app.include_router(cv_router, tags=["cv"])
app.include_router(process_router, tags=["process"])
app.include_router(payment_router, tags=["payment"])
app.include_router(reserve_router, tags=["reserve"])
app.include_router(refund_router, tags=["refund"])
app.include_router(promotion_router, tags=["promotion"])
app.include_router(occupation_router, tags=["occupation"])
app.include_router(offer_router, tags=["offer"])
app.include_router(transfer_router, tags=["transfer"])
app.include_router(dashboard_router, tags=["dashboard"])
app.include_router(stat_router, tags=["stat"])
app.include_router(rating_router, tags=["rating"])
app.include_router(company_info_router, tags=["companyinfo"])
app.include_router(service_router, tags=["service"])
app.include_router(checkout_router, tags=["checkout"])
app.include_router(employee_status_router, tags=["employeestatus"])
app.include_router(assign_agent_router, tags=["assignagent"])

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
