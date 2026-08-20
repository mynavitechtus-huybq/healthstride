from typing import Any, cast

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.core.api_envelope import error_response, success
from app.core.redis import redis_lifespan
from app.features.home.router import router as home_router
from app.features.leaderboard.router import router as leaderboard_router
from app.features.workouts.router import router as workouts_router

app = FastAPI(title="HealthStride API", lifespan=redis_lifespan)
app.include_router(home_router, prefix="/v1")
app.include_router(workouts_router, prefix="/v1")
app.include_router(leaderboard_router, prefix="/v1")


@app.get("/health")
def health() -> dict[str, Any]:
    return success({"status": "ok"})


@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(_request: Request, exc: StarletteHTTPException) -> JSONResponse:
    detail: dict[str, object] = (
        cast(dict[str, object], exc.detail) if isinstance(exc.detail, dict) else {}
    )
    return error_response(
        status_code=exc.status_code,
        code=str(detail.get("code", "REQUEST_FAILED")),
        message=str(detail.get("message", "The request could not be completed.")),
    )


@app.exception_handler(RequestValidationError)
async def request_validation_exception_handler(
    _request: Request, exc: RequestValidationError
) -> JSONResponse:
    details = [
        {
            "loc": list(error["loc"]),
            "msg": error["msg"],
            "type": error["type"],
        }
        for error in exc.errors()
    ]
    return error_response(
        status_code=422,
        code="REQUEST_VALIDATION_FAILED",
        message="Request validation failed.",
        details=details,
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(_request: Request, _exc: Exception) -> JSONResponse:
    return error_response(
        status_code=500,
        code="INTERNAL_SERVER_ERROR",
        message="An unexpected error occurred.",
    )
