# Auth Patterns

## Table of Contents

- Custom authentication middleware
- Session authentication
- JWT authentication
- Request auth context
- Exclusion rules

## Custom Authentication Middleware

Use `AbstractAuthenticationMiddleware` when the credential source is custom.

```python
from dataclasses import dataclass

from litestar.connection import ASGIConnection
from litestar.exceptions import NotAuthorizedException
from litestar.middleware import AbstractAuthenticationMiddleware
from litestar.middleware.authentication import AuthenticationResult


@dataclass
class User:
    id: str


class HeaderTokenAuthMiddleware(AbstractAuthenticationMiddleware):
    async def authenticate_request(self, connection: ASGIConnection) -> AuthenticationResult:
        raw = connection.headers.get("Authorization", "")
        if not raw.startswith("Bearer "):
            raise NotAuthorizedException("Missing bearer token")

        token = raw.removeprefix("Bearer ").strip()
        user = User(id="u-1") if token == "dev-token" else None
        if user is None:
            raise NotAuthorizedException("Invalid token")

        return AuthenticationResult(user=user, auth=token)
```

Guidance:

- Keep this focused on identity retrieval and validation.
- Push authorization policy into guards, not the middleware.

## Session Authentication

Use `SessionAuth` for browser-first apps with server-managed sessions.

```python
from litestar import Litestar, Request
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
    exclude=["/login", "/schema"],
)

app = Litestar(route_handlers=[...], on_app_init=[session_auth.on_app_init])
```

## JWT Authentication

Use `JWTAuth` for token-in-header flows.

```python
from litestar import Litestar, Request, Response, get, post
from litestar.security.jwt import JWTAuth, Token


class User:
    def __init__(self, user_id: str) -> None:
        self.id = user_id


MOCK_DB: dict[str, User] = {}


async def retrieve_user_handler(token: Token, _: Request) -> User | None:
    return MOCK_DB.get(token.sub)


jwt_auth = JWTAuth[User](
    retrieve_user_handler=retrieve_user_handler,
    token_secret="replace-in-production",
    exclude=["/login", "/schema"],
)


@post("/login")
async def login_handler(data: User) -> Response[User]:
    MOCK_DB[data.id] = data
    return jwt_auth.login(identifier=data.id, response_body=data)


@get("/me", sync_to_thread=False)
def me(request: Request[User, Token, object]) -> dict[str, str]:
    return {"id": request.user.id}


app = Litestar(route_handlers=[login_handler, me], on_app_init=[jwt_auth.on_app_init])
```

## Request Auth Context

After authentication runs, route handlers can use `request.user` and `request.auth`.

Guidance:

- Treat these as post-authenticated context.
- Do not use them as a substitute for request parsing or authorization checks.
- Use typed `Request[User, AuthType, StateType]` when strong typing improves clarity.

## Exclusion Rules

Security backends and authentication middleware support `exclude` and `exclude_opt_key` style controls.

Guidance:

- Exclude only explicitly public routes such as login, schema, and health.
- Keep exclusion rules easy to audit.
- Pair exclusions with tests so public surface area does not drift.
