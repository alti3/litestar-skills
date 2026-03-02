---
name: htmx
description: Build HTMX-driven Litestar endpoints for server-rendered partial updates, progressive enhancement, and interaction-focused HTML fragments. Use when implementing HTMX request flows and fragment responses. Do not use for SPA-only JSON APIs that do not exchange HTML fragments.
---

# HTMX

## Execution Workflow

1. Define full-page routes and HTMX fragment routes separately.
2. Detect HTMX request context and return minimal fragment payloads.
3. Keep server-side rendering logic explicit and template-focused.
4. Preserve idempotency and consistent status handling for HTMX interactions.

## Implementation Rules

- Return only the HTML fragment required for the target swap.
- Keep fragment templates small, focused, and independently testable.
- Avoid mixing large business logic blocks into template handlers.
- Treat HTMX routes as first-class endpoints with clear contracts.

## Example Pattern

```python
from litestar import get
from litestar.connection import Request

@get("/users/table")
async def users_table(request: Request) -> object:
    if request.headers.get("HX-Request") == "true":
        return ...  # partial template fragment
    return ...  # full page template
```

## Validation Checklist

- Confirm non-HTMX requests still receive valid full-page behavior.
- Confirm fragment responses include the expected partial markup only.
- Confirm validation and error responses are HTMX-compatible.

## Cross-Skill Handoffs

- Use `templating` for template engine setup and shared layout strategy.
- Use `responses` when headers/status codes drive HTMX client behavior.

## Litestar References

- https://docs.litestar.dev/latest/usage/htmx.html
