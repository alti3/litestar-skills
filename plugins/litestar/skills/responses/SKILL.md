---
name: responses
description: Build Litestar responses using typed return values, Response classes, response headers/cookies, and status-code specific behavior.
---

# Responses

Use this skill for response shaping, status code control, and custom response behavior.

## Workflow

1. Default to typed return values for standard JSON responses.
2. Use `Response(...)` when headers/cookies/media/status must be controlled explicitly.
3. Use response DTO/serialization controls where domain objects need transformation.
4. Ensure error responses are consistent with exception handlers.

## Core Patterns

### Typed Return

```python
from litestar import get

@get("/ping")
async def ping() -> dict[str, str]:
    return {"message": "pong"}
```

### Explicit Response

```python
from litestar import Response, get

@get("/created")
async def created() -> Response[dict[str, str]]:
    return Response({"result": "ok"}, status_code=201)
```

## Response Checklist

- Use precise return types for better schema generation.
- Set explicit status codes for non-default flows.
- Keep response envelope conventions consistent across the API.
- Coordinate response contracts with exception handling.

## Litestar References

- https://docs.litestar.dev/latest/usage/responses.html
- https://docs.litestar.dev/latest/usage/exceptions.html
