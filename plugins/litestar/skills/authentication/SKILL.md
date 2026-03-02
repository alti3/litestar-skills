---
name: authentication
description: Implement authentication and authorization in Litestar using guards, session/JWT auth middleware, and route protection patterns.
---

# Authentication

Use this skill when securing endpoints, adding login/session flows, or enforcing permissions.

## Workflow

1. Choose an auth mechanism (session vs JWT/bearer) based on client architecture.
2. Configure auth middleware/backend.
3. Protect routes with guards and scope checks.
4. Keep unauthenticated and forbidden behaviors explicit and consistent.

## Guard Pattern

```python
from litestar import get
from litestar.connection import ASGIConnection


def require_admin(connection: ASGIConnection, _: object) -> None:
    user = connection.user
    if not user or "admin" not in getattr(user, "roles", []):
        raise PermissionError("admin role required")


@get("/admin", guards=[require_admin])
async def admin_dashboard() -> dict[str, str]:
    return {"status": "ok"}
```

## Security Checklist

- Use HTTPS-only cookie flags and secure token handling.
- Attach auth middleware once at app-level.
- Place authorization close to routes (guards) for clarity.
- Standardize 401 vs 403 responses.

## Litestar References

- https://docs.litestar.dev/latest/usage/security/index.html
- https://docs.litestar.dev/latest/usage/security/guards.html
- https://docs.litestar.dev/latest/usage/security/jwt.html
- https://docs.litestar.dev/latest/usage/security/session.html
