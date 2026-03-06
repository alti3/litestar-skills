# Handler Patterns

## Table of Contents

- Default exception handling behavior
- Response media type and route return type interaction
- Map by exception class
- Map by status code
- Layered exception handling
- App-only `404` and `405`
- Domain exception translation pattern
- Choosing one handler vs many

## Default Exception Handling Behavior

Litestar transforms request-time exceptions into responses by default.

- If the exception is an `HTTPException`, its `status_code` is used.
- Otherwise Litestar falls back to `500 Internal Server Error`.

Design implication:

- Raise `HTTPException` when the handler already knows the transport semantics.
- Use a registered handler when you need to translate another exception type.

## Response Media Type and Route Return Type Interaction

The usage docs note that the default exception response can follow the route's media type. For example, a handler returning `str` defaults to text, so an unhandled exception may become a text response.

```python
from litestar import get


@get(sync_to_thread=False)
def handler(q: int) -> str:
    raise ValueError
```

Guidance:

- Do not assume all exception responses are JSON if the route media type says otherwise.
- Override the exception handler explicitly when error media type must stay uniform across endpoints.

## Map by Exception Class

Use exception-class mappings when the exception type is the stable contract.

```python
from litestar import Litestar, MediaType, Request, Response, get
from litestar.exceptions import HTTPException
from litestar.status_codes import HTTP_500_INTERNAL_SERVER_ERROR


def plain_text_exception_handler(_: Request, exc: Exception) -> Response[str]:
    status_code = getattr(exc, "status_code", HTTP_500_INTERNAL_SERVER_ERROR)
    detail = getattr(exc, "detail", "")
    return Response(media_type=MediaType.TEXT, content=detail, status_code=status_code)


@get("/")
async def index() -> None:
    raise HTTPException(detail="an error occurred", status_code=400)


app = Litestar(
    route_handlers=[index],
    exception_handlers={HTTPException: plain_text_exception_handler},
)
```

Use this when many subclasses should share one formatter.

## Map by Status Code

Use status-code mappings when different exception sources should converge on one HTTP status response.

```python
from litestar import Litestar, MediaType, Request, Response, get
from litestar.exceptions import HTTPException, ValidationException
from litestar.status_codes import HTTP_500_INTERNAL_SERVER_ERROR


def validation_exception_handler(_: Request, exc: ValidationException) -> Response[str]:
    return Response(media_type=MediaType.TEXT, content=f"validation error: {exc.detail}", status_code=400)


def internal_server_error_handler(_: Request, exc: Exception) -> Response[str]:
    return Response(media_type=MediaType.TEXT, content=f"server error: {exc}", status_code=500)


def value_error_handler(_: Request, exc: ValueError) -> Response[str]:
    return Response(media_type=MediaType.TEXT, content=f"value error: {exc}", status_code=400)


@get("/validation-error")
async def validation_error(some_query_param: str) -> str:
    return some_query_param


@get("/server-error")
async def server_error() -> None:
    raise HTTPException()


@get("/value-error")
async def value_error() -> None:
    raise ValueError("this is wrong")


app = Litestar(
    route_handlers=[validation_error, server_error, value_error],
    exception_handlers={
        ValidationException: validation_exception_handler,
        HTTP_500_INTERNAL_SERVER_ERROR: internal_server_error_handler,
        ValueError: value_error_handler,
    },
)
```

Guidance:

- Use status-code mapping for generic fallback formatting.
- Use class mapping where the exception type itself carries business meaning.
- Avoid ambiguous overlap unless you are certain which mapping should win in practice.

## Layered Exception Handling

Litestar supports `exception_handlers` on app, router, controller, and route-handler layers. Lower layers override higher layers.

```python
from litestar import Litestar, Request, Response, get
from litestar.exceptions import HTTPException, ValidationException


def app_exception_handler(request: Request, exc: HTTPException) -> Response[dict[str, object]]:
    return Response(
        content={
            "error": "request failed",
            "path": request.url.path,
            "detail": exc.detail,
            "status_code": exc.status_code,
        },
        status_code=exc.status_code,
    )


def route_handler_exception_handler(request: Request, exc: ValidationException) -> Response[dict[str, str]]:
    return Response(
        content={"error": "validation error", "path": request.url.path},
        status_code=400,
    )


@get("/")
async def index() -> None:
    raise HTTPException(detail="something's gone wrong", status_code=500)


@get("/greet", exception_handlers={ValidationException: route_handler_exception_handler})
async def greet(name: str) -> str:
    return f"hello {name}"


app = Litestar(
    route_handlers=[index, greet],
    exception_handlers={HTTPException: app_exception_handler},
)
```

Guidance:

- Put the shared contract at app scope.
- Override only when a feature area or route truly needs different behavior.
- Keep lower-level overrides narrow so they do not fragment the API contract accidentally.

## App-Only `404` and `405`

The usage docs are explicit: `404 Not Found` and `405 Method Not Allowed` are raised by Litestar's ASGI router and are handled only by app-level exception handlers.

Pattern:

```python
from litestar import Litestar, Request, Response
from litestar.exceptions import MethodNotAllowedException, NotFoundException


def not_found_handler(request: Request, _: NotFoundException) -> Response[dict[str, str]]:
    return Response(content={"code": "not_found", "path": request.url.path}, status_code=404)


def method_not_allowed_handler(request: Request, _: MethodNotAllowedException) -> Response[dict[str, str]]:
    return Response(content={"code": "method_not_allowed", "path": request.url.path}, status_code=405)


app = Litestar(
    route_handlers=[...],
    exception_handlers={
        NotFoundException: not_found_handler,
        MethodNotAllowedException: method_not_allowed_handler,
    },
)
```

Do not attempt to customize these two responses at router, controller, or handler scope.

## Domain Exception Translation Pattern

Keep business exceptions transport-agnostic and translate them once at the framework edge.

```python
from dataclasses import dataclass

from litestar import Litestar, Request, Response, post


@dataclass
class InventoryError(Exception):
    sku: str
    reason: str


def inventory_error_handler(_: Request, exc: InventoryError) -> Response[dict[str, str]]:
    return Response(
        content={
            "code": "inventory_error",
            "message": exc.reason,
            "sku": exc.sku,
        },
        status_code=409,
    )


@post("/reserve")
async def reserve_item() -> None:
    raise InventoryError(sku="ABC-123", reason="item is out of stock")


app = Litestar(
    route_handlers=[reserve_item],
    exception_handlers={InventoryError: inventory_error_handler},
)
```

This keeps domain code free of HTTP imports while still yielding deterministic API behavior.


## OpenAPI Alignment

Exception handling and OpenAPI documentation should stay in sync.

Guidance:

- If a route documents security requirements, its likely `401` and `403` outcomes should not surprise API consumers.
- When an exception handler changes the media type or envelope shape, verify the route's documented responses and examples.
- Use route-level `raises` or documented responses through `litestar-openapi` only when they reflect real runtime behavior.
- Keep app-level fallback handlers and route-specific documented errors aligned.

## Choosing One Handler vs Many

The usage docs note that one switching handler or many specialized handlers can both be valid.

Prefer one handler when:

- Every error must use the same envelope and media type.
- The branching logic is small and stable.

Prefer multiple handlers when:

- Different exception families have materially different payloads.
- Ownership is split across feature areas.
- Separate testing and maintenance boundaries are clearer.
