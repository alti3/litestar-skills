---
name: litestar-middleware
description: Design and apply Litestar middleware for cross-cutting concerns such as CORS, compression, request enrichment, policy enforcement, and ASGI pipeline control. Use when behavior must wrap broad route sets consistently. Do not use for route-specific business rules that belong in handlers or services.
---

# Middleware

## Execution Workflow

1. Determine whether built-in middleware covers the requirement.
2. Add middleware in explicit execution order at app initialization.
3. Implement custom middleware only when behavior is truly cross-cutting.
4. Validate middleware interaction with hooks, exception handlers, and auth.

## Implementation Rules

- Keep middleware focused on one cross-cutting responsibility.
- Avoid placing domain business logic in middleware.
- Keep middleware non-blocking and side effects observable.
- Document ordering assumptions when multiple middleware components interact.

## Example Pattern

```python
from litestar.middleware import AbstractMiddleware

class RequestTimingMiddleware(AbstractMiddleware):
    async def __call__(self, scope, receive, send):
        return await self.app(scope, receive, send)
```

## Validation Checklist

- Confirm middleware executes in the expected order.
- Confirm behavior is correct for both success and failure paths.
- Confirm headers/context mutations do not leak across requests.

## Cross-Skill Handoffs

- Use `lifecycle-hooks` for hook-stage logic rather than ASGI wrapping.
- Use `authentication`, `logging`, and `metrics` for domain-specific middleware outcomes.

## Litestar References

- https://docs.litestar.dev/latest/usage/middleware/index.html
- https://docs.litestar.dev/latest/usage/middleware/using-middleware.html
- https://docs.litestar.dev/latest/usage/middleware/builtin-middleware.html
- https://docs.litestar.dev/latest/usage/middleware/creating-middleware.html
