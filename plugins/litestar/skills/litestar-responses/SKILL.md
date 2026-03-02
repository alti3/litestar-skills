---
name: litestar-responses
description: Build Litestar responses with typed returns, response classes, headers/cookies, status control, custom response classes, and redirect/file/streaming patterns. Use when shaping outbound API behavior or correcting response contracts. Do not use for request parsing or authentication policy implementation.
---

# Responses

## Execution Workflow

1. Start with typed return values for standard JSON responses.
2. Use explicit response classes when controlling status, headers, media type, or cookies.
3. Apply specialized responses (redirect, file, stream, template) when required.
4. Keep success and error response envelopes consistent.

## Implementation Rules

- Declare precise return types for schema accuracy.
- Set explicit status codes for non-default behavior.
- Keep header/cookie setting centralized and policy-compliant.
- Align response behavior with exception-handling contracts.

## Example Pattern

```python
from litestar import Response, get

@get("/created")
async def created() -> Response[dict[str, str]]:
    return Response({"result": "ok"}, status_code=201)
```

## Validation Checklist

- Confirm status codes, headers, and bodies match endpoint contract.
- Confirm streaming and file responses are memory-safe and correctly typed.
- Confirm redirects and custom response classes preserve OpenAPI intent.

## Cross-Skill Handoffs

- Use `exception-handling` for error envelope/mapping strategy.
- Use `openapi` when response modeling changes schema behavior.

## Litestar References

- https://docs.litestar.dev/latest/usage/responses.html
- https://docs.litestar.dev/latest/usage/responses.html#using-response-classes
- https://docs.litestar.dev/latest/usage/responses.html#response-status-codes
- https://docs.litestar.dev/latest/usage/responses.html#redirect-responses
- https://docs.litestar.dev/latest/usage/responses.html#streaming-response
- https://docs.litestar.dev/latest/usage/responses.html#file-responses
