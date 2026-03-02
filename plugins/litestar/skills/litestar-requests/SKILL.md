---
name: litestar-requests
description: Handle Litestar request parsing and validation for path/query/header/cookie/body/multipart inputs with explicit typing and deterministic client-error handling. Use when implementing or fixing inbound contract parsing. Do not use for response serialization concerns.
---

# Requests

## Execution Workflow

1. Type route parameters and body models explicitly.
2. Apply parameter constraints and aliases for query/header/cookie fields.
3. Validate multipart and file upload paths with strict size/type policy.
4. Keep transport validation separate from business-domain validation.

## Implementation Rules

- Avoid untyped `dict` payloads when schema is known.
- Prefer strict domain types (UUID, enums, datetime, constrained strings/ints).
- Normalize malformed input behavior into stable `4xx` contracts.
- Keep parsing rules close to route definitions for readability.

## Example Pattern

```python
from litestar import get
from litestar.params import Parameter

@get("/search")
async def search(limit: int = Parameter(ge=1, le=100, query="limit")) -> dict[str, int]:
    return {"limit": limit}
```

## Validation Checklist

- Confirm coercion and validation rules match API docs.
- Confirm malformed inputs fail with deterministic error payloads.
- Confirm large payload and multipart handling does not exhaust memory.

## Cross-Skill Handoffs

- Use `dto` and `custom-types` for advanced input transformations.
- Use `file-uploads` for deep multipart security handling.

## Litestar References

- https://docs.litestar.dev/latest/usage/requests.html
- https://docs.litestar.dev/latest/usage/routing/parameters.html
