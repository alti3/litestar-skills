# Litestar Security Patterns (Comprehensive)

Use this playbook when implementing or reviewing end-to-end security in Litestar 2 APIs.

## Table of Contents

1. Security Architecture Baseline
2. Abstract Authentication Middleware
3. Security Backends
4. Guards (Authorization)
5. Excluding and Including Endpoints
6. JWT Patterns
7. Secret Data Structures
8. Error Contract and Security Logging
9. Testing Matrix
10. Production Hardening Checklist

## 1. Security Architecture Baseline

Security layers should be explicit and independently testable:

1. Transport and perimeter: TLS, trusted proxy config, allowed hosts/CORS.
2. Authentication: session/JWT/custom middleware identity establishment.
3. Authorization: guards for role, scope, ownership, or policy checks.
4. Secret hygiene: `SecretString`/`SecretBytes` and secure configuration flow.
5. Observability: log outcomes, never secrets.

Recommended route classes:

- Public: health checks, docs, login bootstrap.
- Authenticated: user profile and ordinary domain operations.
- Privileged: admin/operator endpoints requiring stricter guards.

## 2. Abstract Authentication Middleware

Use `AbstractAuthenticationMiddleware` when built-in backends do not fit your identity source.

```python
from __future__ import annotations

from dataclasses import dataclass

from litestar import Litestar, get
from litestar.connection import ASGIConnection
from litestar.datastructures.state import State
from litestar.exceptions import NotAuthorizedException
from litestar.middleware import AbstractAuthenticationMiddleware
from litestar.middleware.authentication import AuthenticationResult


@dataclass
class User:
    id: str
    roles: set[str]


class HeaderTokenAuthMiddleware(AbstractAuthenticationMiddleware):
    async def authenticate_request(self, connection: ASGIConnection) -> AuthenticationResult:
        raw = connection.headers.get("Authorization", "")
        if not raw.startswith("Bearer "):
            raise NotAuthorizedException("Missing bearer token")

        token = raw.removeprefix("Bearer ").strip()
        user = await self._resolve_user(token=token, state=connection.app.state)
        if user is None:
            raise NotAuthorizedException("Invalid token")

        return AuthenticationResult(user=user, auth=token)

    async def _resolve_user(self, token: str, state: State) -> User | None:
        # Replace with real verification and datastore lookup.
        if token == "dev-token":
            return User(id="u-1", roles={"admin"})
        return None


@get("/me")
async def me(connection: ASGIConnection) -> dict[str, str]:
    user = connection.user
    return {"id": user.id if user else "anonymous"}


app = Litestar(
    route_handlers=[me],
    middleware=[
        HeaderTokenAuthMiddleware(
            exclude="/schema",
            exclude_opt_key="exclude_from_auth",
        )
    ],
)
```

Implementation notes:

- Return `AuthenticationResult(user=..., auth=...)` for valid credentials.
- Raise `NotAuthorizedException` for missing/invalid authentication.
- Keep auth middleware focused on identity retrieval and validation only.

## 3. Security Backends

Prefer built-ins for reliability and consistent framework behavior.

### 3.1 SessionAuth

Use for browser-first apps where server-managed sessions are preferred.

```python
from litestar import Litestar, Request, get
from litestar.response import Response
from litestar.security.session_auth import SessionAuth


class User:
    def __init__(self, user_id: str) -> None:
        self.id = user_id


async def retrieve_user_handler(session: dict[str, str], _: Request) -> User | None:
    user_id = session.get("user_id")
    return User(user_id) if user_id else None


session_auth = SessionAuth[User, dict[str, str]](
    retrieve_user_handler=retrieve_user_handler,
    session_backend_config={"secret": "replace-in-production"},
    exclude=["/health", "/schema"],
)


@get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


app = Litestar(route_handlers=[health], on_app_init=[session_auth.on_app_init])
```

### 3.2 JWTAuth (Authorization header)

Use for API clients and service-to-service traffic.

```python
from litestar import Litestar
from litestar.security.jwt import JWTAuth


jwt_auth = JWTAuth[
    dict[str, object]
](
    token_secret="replace-in-production",
    retrieve_user_handler=lambda token, _: token,
    accepted_audiences={"api-clients"},
    accepted_issuers={"auth-service"},
    exclude=["/health", "/schema"],
)

app = Litestar(route_handlers=[], on_app_init=[jwt_auth.on_app_init])
```

### 3.3 JWTCookieAuth

Use for browser clients when token-in-cookie behavior is required.

```python
from litestar import Litestar
from litestar.security.jwt import JWTCookieAuth

jwt_cookie_auth = JWTCookieAuth[
    dict[str, object]
](
    token_secret="replace-in-production",
    retrieve_user_handler=lambda token, _: token,
    exclude=["/health", "/schema"],
)

app = Litestar(route_handlers=[], on_app_init=[jwt_cookie_auth.on_app_init])
```

### 3.4 OAuth2PasswordBearerAuth

Use when exposing OAuth2 password flow for token issuance semantics.

```python
from litestar import Litestar
from litestar.security.jwt import OAuth2PasswordBearerAuth


oauth2_auth = OAuth2PasswordBearerAuth[
    dict[str, object]
](
    token_secret="replace-in-production",
    retrieve_user_handler=lambda token, _: token,
    token_url="/auth/token",
    exclude=["/auth/token", "/health", "/schema"],
)

app = Litestar(route_handlers=[], on_app_init=[oauth2_auth.on_app_init])
```

## 4. Guards (Authorization)

Guards run after authentication and control access per route or router.

Guard signature pattern:

```python
from litestar.connection import ASGIConnection
from litestar.handlers.base import BaseRouteHandler


def guard(connection: ASGIConnection, handler: BaseRouteHandler) -> None:
    ...
```

Role and scope guards:

```python
from litestar import get
from litestar.connection import ASGIConnection
from litestar.exceptions import PermissionDeniedException


def require_roles(*roles: str):
    def _guard(connection: ASGIConnection, _: object) -> None:
        user = connection.user
        if not user:
            raise PermissionDeniedException("Authenticated user required")
        owned = set(getattr(user, "roles", []))
        if not set(roles).issubset(owned):
            raise PermissionDeniedException("Insufficient roles")

    return _guard


@get("/admin/reports", guards=[require_roles("admin")])
async def admin_reports() -> dict[str, str]:
    return {"status": "ok"}
```

Ownership guard example:

```python
from litestar import get
from litestar.connection import ASGIConnection
from litestar.exceptions import PermissionDeniedException


def require_owner_or_admin(connection: ASGIConnection, _: object) -> None:
    user = connection.user
    if not user:
        raise PermissionDeniedException("Authentication required")

    requested_user_id = connection.path_params.get("user_id")
    if requested_user_id != getattr(user, "id", None) and "admin" not in getattr(user, "roles", []):
        raise PermissionDeniedException("Owner or admin required")


@get("/users/{user_id:str}", guards=[require_owner_or_admin])
async def get_user(user_id: str) -> dict[str, str]:
    return {"user_id": user_id}
```

Guard best practices:

- Keep guards pure; no writes and no external side effects.
- Use small composable guards rather than large monolithic policies.
- Raise `PermissionDeniedException` for authorization failures.

## 5. Excluding and Including Endpoints

Litestar supports multiple exclusion methods:

- `exclude`: explicit path string, regex, list, or set.
- `exclude_opt_key`: skip auth when route has matching `opt` flag.
- Per-handler exclusion option (backend-dependent).

Regex exclusion pattern:

```python
import re

from litestar import Litestar
from litestar.security.jwt import JWTAuth

jwt_auth = JWTAuth[
    dict[str, object]
](
    token_secret="replace-in-production",
    retrieve_user_handler=lambda token, _: token,
    exclude=re.compile(r"^/public(?:/|$)"),
)

app = Litestar(route_handlers=[], on_app_init=[jwt_auth.on_app_init])
```

Opt-key exclusion pattern:

```python
from litestar import Litestar, get
from litestar.security.jwt import JWTAuth


@get("/health", opt={"public": True})
async def health() -> dict[str, str]:
    return {"status": "ok"}


jwt_auth = JWTAuth[
    dict[str, object]
](
    token_secret="replace-in-production",
    retrieve_user_handler=lambda token, _: token,
    exclude_opt_key="public",
)

app = Litestar(route_handlers=[health], on_app_init=[jwt_auth.on_app_init])
```

Safety guidance:

- Prefer explicit path exclusions for high-risk systems.
- Keep exclusion rules in one place and review during security audits.
- Avoid broad wildcard patterns unless intentionally public.

## 6. JWT Patterns

Core JWT capabilities in Litestar security backends include:

- Token decoding and validation.
- Audience and issuer restrictions (`accepted_audiences`, `accepted_issuers`).
- Revocation hooks (`revoked_token_handler`).

JWT auth with revocation handler:

```python
from litestar import Litestar
from litestar.security.jwt import JWTAuth, Token


def revoked_token_handler(token: Token, _: object) -> bool:
    # Replace with a real revocation store (Redis/DB/cache).
    return token.jti in {"revoked-jti-1", "revoked-jti-2"}


jwt_auth = JWTAuth[
    dict[str, object]
](
    token_secret="replace-in-production",
    retrieve_user_handler=lambda token, _: token,
    accepted_audiences={"api-clients"},
    accepted_issuers={"auth-service"},
    revoked_token_handler=revoked_token_handler,
    exclude=["/health", "/schema"],
)

app = Litestar(route_handlers=[], on_app_init=[jwt_auth.on_app_init])
```

JWT hardening guidance:

- Keep token lifetime short and rotate secrets/keys regularly.
- Validate issuer and audience in multi-service systems.
- Enforce algorithm policy and do not accept weak algorithms.
- Implement revocation for logout and incident response.

## 7. Secret Data Structures

Use secret wrappers for sensitive values to avoid accidental disclosure.

```python
from litestar.datastructures.secret_values import SecretBytes, SecretString

jwt_secret = SecretString("replace-in-production")
signing_key = SecretBytes(b"replace-in-production")

# Only unwrap exactly where the cryptographic call needs raw material.
raw_secret = jwt_secret.get_secret_value()
```

Guidance:

- Keep unwrapped values scoped tightly and short-lived.
- Never print raw secret values in logs or exception messages.
- Prefer environment/secret manager loading into secret wrappers.

## 8. Error Contract and Security Logging

Security responses should be predictable:

- `401 Unauthorized`: missing/invalid credentials.
- `403 Forbidden`: authenticated but not permitted.

Logging recommendations:

- Log request id, principal id (if known), route, decision (allow/deny), reason code.
- Do not log raw access tokens, cookies, or decrypted secret values.
- Standardize audit event format for SIEM/search workflows.

## 9. Testing Matrix

Minimum tests per protected route:

1. No credentials -> `401`.
2. Invalid credentials -> `401`.
3. Valid credentials with insufficient privilege -> `403`.
4. Valid privileged credentials -> success response.
5. Expired token -> `401`.
6. Revoked token -> `401`.

Suggested integration test skeleton:

```python
from litestar.testing import TestClient


def test_admin_requires_role(client: TestClient) -> None:
    response = client.get("/admin/reports", headers={"Authorization": "Bearer user-token"})
    assert response.status_code == 403
```

## 10. Production Hardening Checklist

- Enforce HTTPS and secure cookie flags where cookies are used.
- Keep auth middleware/backend configured once at app init (no per-request mutation).
- Validate all exclusion rules against a route inventory.
- Implement key/secret rotation process and incident playbook.
- Keep OpenAPI security schemes in sync with actual enforcement.
- Add regression tests for every past auth/security incident.

## Source Links

- https://docs.litestar.dev/2/usage/security
- https://docs.litestar.dev/2/usage/security/abstract-authentication-middleware.html
- https://docs.litestar.dev/2/usage/security/security-backends.html
- https://docs.litestar.dev/2/usage/security/guards.html
- https://docs.litestar.dev/2/usage/security/excluding-and-including-endpoints.html
- https://docs.litestar.dev/2/usage/security/jwt.html
- https://docs.litestar.dev/2/usage/security/secret-datastructures.html
