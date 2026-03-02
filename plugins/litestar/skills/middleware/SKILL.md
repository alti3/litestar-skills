---
name: middleware
description: Design and apply Litestar middleware for cross-cutting concerns such as CORS, compression, timing, request enrichment, and policy enforcement.
---

# Middleware

Use this skill for cross-cutting behavior that should apply across many routes.

## Workflow

1. Decide whether built-in middleware is enough (CORS, compression, etc.).
2. Add middleware at app level in execution order.
3. Use custom middleware only for truly cross-cutting concerns.
4. Keep middleware side effects observable (logging/metrics).

## Custom Middleware Pattern

```python
from litestar.middleware import AbstractMiddleware


class RequestTimingMiddleware(AbstractMiddleware):
    async def __call__(self, scope, receive, send):
        return await self.app(scope, receive, send)
```

## Checklist

- Keep middleware focused and minimal.
- Avoid business logic in middleware.
- Be explicit about ordering when middleware interacts.
- Validate behavior for both success and error paths.

## Litestar References

- https://docs.litestar.dev/latest/usage/middleware/index.html
- https://docs.litestar.dev/latest/usage/middleware/using-middleware.html
- https://docs.litestar.dev/latest/usage/middleware/builtin-middleware.html
- https://docs.litestar.dev/latest/usage/middleware/creating-middleware.html
