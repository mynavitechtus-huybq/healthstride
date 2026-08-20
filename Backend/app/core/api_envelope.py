from typing import Any

from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field


class ErrorDetail(BaseModel):
    code: str
    message: str
    details: Any | None = None


class ErrorEnvelope(BaseModel):
    data: None = None
    meta: dict[str, Any] = Field(default_factory=dict)
    error: ErrorDetail


class SuccessEnvelope[DataT](BaseModel):
    data: DataT
    meta: dict[str, Any] = Field(default_factory=dict)
    error: None = None


def success(data: Any, meta: dict[str, Any] | None = None) -> dict[str, Any]:
    return {
        "data": data,
        "meta": {} if meta is None else meta,
        "error": None,
    }


def error_response(
    status_code: int,
    code: str,
    message: str,
    details: Any | None = None,
) -> JSONResponse:
    error: dict[str, Any] = {"code": code, "message": message}
    if details is not None:
        error["details"] = details

    return JSONResponse(
        status_code=status_code,
        content={"data": None, "meta": {}, "error": error},
    )
