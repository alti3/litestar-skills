# Built-In Exceptions

## Table of Contents

- Exception categories
- `HTTPException` basics
- Built-in HTTP exception subclasses
- Validation exception guidance
- `HTTPException` headers and `extra`
- Configuration exceptions
- WebSocket exceptions

## Exception Categories

Litestar distinguishes between two broad categories:

- Configuration and startup exceptions: raised during application setup, plugin initialization, or misconfiguration. These behave like normal Python exceptions and are not request-time response handling.
- Request-time exceptions: raised in route handlers, dependencies, or middleware and transformed into responses for the client.

Design implication:

- Do not design API error envelopes around startup failures.
- Do design deterministic response behavior for request-time exceptions.

## `HTTPException` Basics

`HTTPException` is the base HTTP-aware exception type used for request-time failures.

Default serialized shape from the usage docs:

```json
{
  "status_code": 500,
  "detail": "Internal Server Error",
  "extra": {}
}
```

Minimal pattern:

```python
from litestar import get
from litestar.exceptions import HTTPException


@get("/items/{item_id:int}")
async def get_item(item_id: int) -> dict[str, int]:
    if item_id < 1:
        raise HTTPException(status_code=400, detail="item_id must be positive")
    return {"item_id": item_id}
```

Use this when the route handler already knows the correct HTTP semantics.

## Built-In HTTP Exception Subclasses

The usage docs call out these common subclasses:

- `ValidationException`: `400`
- `NotAuthorizedException`: `401`
- `PermissionDeniedException`: `403`
- `NotFoundException`: `404`
- `InternalServerException`: `500`
- `ServiceUnavailableException`: `503`

The API reference also includes `ClientException` and `TooManyRequestsException` (`429`).

Pattern:

```python
from litestar import get
from litestar.exceptions import NotFoundException, TooManyRequestsException


@get("/records/{record_id:int}")
async def read_record(record_id: int) -> dict[str, int]:
    if record_id == 404:
        raise NotFoundException(detail="record not found")
    if record_id == 429:
        raise TooManyRequestsException(detail="retry later")
    return {"record_id": record_id}
```

Guidance:

- Prefer the built-in subclass when it exactly matches the HTTP semantics.
- Use plain `HTTPException` when you need an uncommon status code or custom combination of fields.

## Validation Exception Guidance

When a value fails validation, Litestar raises `ValidationException` and places validation details in `extra`.

Important warning from the usage docs:

- Validation messages are made available to API consumers by default.
- If that detail level is too revealing, replace or reshape the response content in a handler.

Pattern: sanitize validation output

```python
from litestar import Litestar, Request, Response
from litestar.exceptions import ValidationException


def validation_exception_handler(_: Request, exc: ValidationException) -> Response[dict[str, object]]:
    return Response(
        content={
            "code": "validation_error",
            "message": "request validation failed",
            "details": exc.extra or {},
        },
        status_code=400,
    )


app = Litestar(route_handlers=[...], exception_handlers={ValidationException: validation_exception_handler})
```

Use a stricter envelope than the default when field-level diagnostics should be curated.

## `HTTPException` Headers and `extra`

The API reference shows `HTTPException` accepts:

- `detail`
- `status_code`
- `headers`
- `extra`

Pattern: attach headers and structured metadata

```python
from litestar import get
from litestar.exceptions import HTTPException


@get("/limited")
async def limited() -> None:
    raise HTTPException(
        status_code=429,
        detail="rate limit exceeded",
        headers={"Retry-After": "60"},
        extra={"code": "rate_limited", "retry_after_seconds": 60},
    )
```

Guidance:

- Use `headers` for transport-level hints such as `Retry-After`.
- Use `extra` for machine-readable metadata only when clients are expected to consume it.
- Keep `detail` human-readable and safe to expose.

## Configuration Exceptions

The usage docs call out:

- `MissingDependencyException` for missing optional dependencies required by features or plugins.
- `ImproperlyConfiguredException` for invalid application configuration.

These are setup-time concerns. Treat them as application wiring failures, not API response design problems.

## WebSocket Exceptions

The API reference also includes websocket-specific exceptions:

- `WebSocketException(detail=..., code=4500)` for websocket-related failures.
- `WebSocketDisconnect(detail=..., code=1000)` for disconnect events.

Guidance:

- Do not force websocket errors through HTTP exception patterns.
- Keep websocket exception handling separate from HTTP JSON error-envelope design.
