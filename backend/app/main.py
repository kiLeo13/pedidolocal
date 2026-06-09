from uuid import uuid4

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

from app.api.routes import audit, auth, catalog, health, orders
from app.core.config import get_settings
from app.core.exceptions import DomainError


def create_app() -> FastAPI:
    settings = get_settings()
    api = FastAPI(title=settings.app_name)

    @api.middleware("http")
    async def request_id_middleware(request: Request, call_next):
        request_id = request.headers.get("X-Request-ID") or str(uuid4())
        request.state.request_id = request_id
        content_length = request.headers.get("content-length")
        body_is_too_large = (
            content_length
            and content_length.isdigit()
            and int(content_length) > settings.max_request_body_bytes
        )
        if body_is_too_large:
            return JSONResponse(
                status_code=status.HTTP_413_CONTENT_TOO_LARGE,
                content={"detail": "request body is too large"},
                headers={"X-Request-ID": request_id},
            )
        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        return response

    @api.exception_handler(DomainError)
    async def domain_error_handler(_request: Request, exc: DomainError):
        return JSONResponse(status_code=exc.status_code, content={"detail": exc.message})

    api.include_router(health.router)
    api.include_router(auth.router)
    api.include_router(catalog.router)
    api.include_router(orders.router)
    api.include_router(audit.router)
    return api


app = create_app()
