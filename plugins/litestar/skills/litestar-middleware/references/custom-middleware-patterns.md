# Custom Middleware Patterns

## Table of Contents

- `ASGIMiddleware`
- `MiddlewareProtocol`
- `AbstractMiddleware`
- `DefineMiddleware`
- Mutation guidance

## `ASGIMiddleware`

Use `ASGIMiddleware` for new configurable middleware.

```python
import anyio

from litestar import Litestar
from litestar.middleware import ASGIMiddleware
from litestar.types import ASGIApp, Receive, Scope, Send


class TimeoutMiddleware(ASGIMiddleware):
    def __init__(self, timeout: float) -> None:
        self.timeout = timeout

    async def handle(self, scope: Scope, receive: Receive, send: Send, next_app: ASGIApp) -> None:
        with anyio.move_on_after(self.timeout):
            await next_app(scope, receive, send)


app = Litestar(route_handlers=[...], middleware=[TimeoutMiddleware(timeout=5)])
```

Guidance:

- Prefer this style for production custom middleware.
- Use built-in skip controls such as `scopes`, `exclude_path_pattern`, and `exclude_opt_key` when they fit.

## `MiddlewareProtocol`

Use `MiddlewareProtocol` for very small low-level wrappers.

Guidance:

- Implement `__init__(self, app: ASGIApp, **kwargs)` and `__call__(...)`.
- Keep protocol-style middleware minimal and focused.

## `AbstractMiddleware`

`AbstractMiddleware` remains available for compatibility and migration scenarios.

Guidance:

- Prefer `ASGIMiddleware` for new code.
- Use `AbstractMiddleware` when maintaining an existing codebase that already depends on it.

## `DefineMiddleware`

Use `DefineMiddleware` to supply args and kwargs to a middleware factory or class.

```python
from litestar import Litestar
from litestar.middleware import DefineMiddleware
from litestar.types import ASGIApp, Receive, Scope, Send


def middleware_factory(my_arg: int, *, app: ASGIApp, my_kwarg: str) -> ASGIApp:
    async def my_middleware(scope: Scope, receive: Receive, send: Send) -> None:
        await app(scope, receive, send)
    return my_middleware


app = Litestar(
    route_handlers=[...],
    middleware=[DefineMiddleware(middleware_factory, 1, my_kwarg="abc")],
)
```

## Mutation Guidance

Practical mutation rules from the middleware docs:

- If mutating incoming request data, modify the ASGI `scope` because it is the source of truth.
- If mutating outgoing ASGI response messages, wrap `send` and inspect `message["type"]`.
- If you only need response-object mutation, prefer lifecycle hooks instead of middleware.
