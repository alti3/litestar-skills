---
name: litestar-security
description: Build secure Litestar APIs using authentication middleware, built-in security backends, guards, endpoint inclusion/exclusion controls, JWT validation, and secret-safe data handling. Use when implementing or auditing end-to-end API security controls. Do not use for non-security business logic, generic request parsing, or unrelated transport concerns.
---

# Security

Use this skill when a Litestar service needs practical, defense-in-depth security implementation, not only authentication wiring.

For full implementation patterns, open [references/security-patterns.md](references/security-patterns.md).

## Execution Workflow

1. Define security boundaries first: public endpoints, authenticated endpoints, and privileged endpoints.
2. Pick the auth mechanism (session, JWT header, JWT cookie, or custom middleware) based on client type and trust assumptions.
3. Apply auth once at app scope, then protect routes with guards for authorization checks.
4. Explicitly configure endpoint inclusion/exclusion (`exclude`, `exclude_opt_key`, `opt`) to prevent accidental exposure.
5. Centralize 401/403 behavior and make security failures predictable for clients.
6. Store secrets using `SecretString` / `SecretBytes`, never plain strings in logs or repr output.
7. Validate with boundary tests: missing credentials, invalid credentials, expired/revoked tokens, and insufficient scopes/roles.

## Implementation Rules

- Keep authentication (who are you) separate from authorization (what can you do).
- Prefer built-in security backends before writing custom middleware.
- Keep guard functions deterministic and side-effect free.
- Use explicit allow/deny rules; avoid implicit defaults you cannot audit quickly.
- Do not hardcode key material or token secrets.
- Make exclusion rules narrow and reviewable.

## Quick Patterns

### Pattern 1: Guard-based authorization

```python
from litestar import get
from litestar.connection import ASGIConnection
from litestar.exceptions import PermissionDeniedException


def require_admin(connection: ASGIConnection, _: object) -> None:
    user = connection.user
    if not user or "admin" not in getattr(user, "roles", []):
        raise PermissionDeniedException("admin role required")

@get("/admin", guards=[require_admin])
async def admin_dashboard() -> dict[str, str]:
    return {"status": "ok"}
```

### Pattern 2: Opt-based exclusions for public routes

```python
from litestar import Litestar, get
from litestar.security.jwt import JWTAuth


@get("/health", opt={"exclude_from_auth": True})
async def healthcheck() -> dict[str, str]:
    return {"status": "ok"}

app = Litestar(
    route_handlers=[healthcheck],
    on_app_init=[
        JWTAuth[dict[str, object]](
            token_secret="replace-in-production",
            retrieve_user_handler=lambda token, _: token,
            exclude_opt_key="exclude_from_auth",
            exclude=["/schema"],
        ).on_app_init
    ],
)
```

### Pattern 3: Safe secret handling

```python
from litestar.datastructures.secret_values import SecretString

jwt_secret = SecretString("super-secret")
# Avoid logging plain secrets; use .get_secret_value() only where required.
```

## Validation Checklist

- Confirm unauthenticated requests receive `401` on protected routes.
- Confirm unauthorized (insufficient role/scope) requests receive `403`.
- Confirm public routes stay public only when explicitly marked.
- Confirm revoked and expired JWTs are rejected.
- Confirm token audience/issuer validation is enabled where applicable.
- Confirm secrets do not appear in logs, tracebacks, or repr output.
- Confirm test coverage includes both success and negative security paths.

## Cross-Skill Handoffs

- Use `litestar-authentication` when the task is narrow and auth-only.
- Use `litestar-exception-handling` to standardize `401/403` response contracts.
- Use `litestar-testing` for auth boundary and regression tests.
- Use `litestar-openapi` to publish security scheme docs for clients.

## Litestar References

- https://docs.litestar.dev/2/usage/security
- https://docs.litestar.dev/2/usage/security/abstract-authentication-middleware.html
- https://docs.litestar.dev/2/usage/security/security-backends.html
- https://docs.litestar.dev/2/usage/security/guards.html
- https://docs.litestar.dev/2/usage/security/excluding-and-including-endpoints.html
- https://docs.litestar.dev/2/usage/security/jwt.html
- https://docs.litestar.dev/2/usage/security/secret-datastructures.html
