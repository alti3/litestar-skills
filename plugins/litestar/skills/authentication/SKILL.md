---
name: authentication
description: Implement Litestar authentication and authorization using custom authentication middleware, built-in security backends, guards, endpoint inclusion/exclusion rules, JWT backends, and secret handling. Use when securing routes, adding login/session/token flows, or enforcing permissions. Do not use for non-security request parsing or unrelated transport concerns.
---

# Authentication

## Execution Workflow

1. Choose an authentication strategy (session, JWT, or custom backend) based on client and trust boundaries.
2. Implement backend or middleware and attach it once at application scope.
3. Apply route protection with guards and explicit include/exclude endpoint rules.
4. Normalize unauthorized (`401`) and forbidden (`403`) behavior across handlers.
5. Handle secrets and key material with secure storage and rotation expectations.

## Implementation Rules

- Keep authentication (identity) and authorization (permissions) separate.
- Favor built-in security backends unless custom behavior is required.
- Keep guard logic deterministic, side-effect free, and close to routes.
- Never hardcode secrets; load from secure env/config sources.

## Example Pattern

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

## Validation Checklist

- Confirm protected endpoints reject missing/invalid credentials.
- Confirm role/scope checks reject insufficient privileges.
- Confirm excluded endpoints remain accessible when intended.
- Confirm token/session expiration and revocation behaviors are tested.
- Confirm logs and errors never leak raw secrets or full tokens.

## Cross-Skill Handoffs

- Use `requests` for input validation before auth logic executes.
- Use `exception-handling` to standardize auth error contracts.
- Use `testing` to harden auth boundary coverage.

## Litestar References

- https://docs.litestar.dev/latest/usage/security/index.html
- https://docs.litestar.dev/latest/usage/security/abstract-authentication-middleware.html
- https://docs.litestar.dev/latest/usage/security/security-backends.html
- https://docs.litestar.dev/latest/usage/security/guards.html
- https://docs.litestar.dev/latest/usage/security/excluding-and-including-endpoints.html
- https://docs.litestar.dev/latest/usage/security/jwt.html
- https://docs.litestar.dev/latest/usage/security/secret-datastructures.html
