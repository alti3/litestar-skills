# Builtin And Ordering

## Table of Contents

- Middleware fundamentals
- Call order and layer precedence
- Router-generated `404` and `405`
- Built-in middleware selection

## Middleware Fundamentals

Middleware is any callable that accepts at least an `app` kwarg and returns an `ASGIApp`.

```python
from litestar import Litestar
from litestar.types import ASGIApp, Receive, Scope, Send


def middleware_factory(app: ASGIApp) -> ASGIApp:
    async def my_middleware(scope: Scope, receive: Receive, send: Send) -> None:
        await app(scope, receive, send)
    return my_middleware


app = Litestar(route_handlers=[...], middleware=[middleware_factory])
```

Guidance:

- The injected `app` is the next ASGI app in the chain, not the `Litestar` instance.
- Keep the wrapper focused and scope-aware.

## Call Order And Layer Precedence

The docs describe these ordering rules:

- Within one layer, middleware execute in the order listed.
- Across layers, traversal follows application -> router -> controller -> handler.

Guidance:

- Treat order as part of behavior, not an implementation detail.
- Test interactions explicitly when multiple middleware depend on each other.

## Router-Generated `404` And `405`

The middleware docs note that `NotFoundException` and `MethodNotAllowedException` are raised by the ASGI router before the middleware stack.

Guidance:

- Do not try to customize these in middleware.
- Handle them with app-level exception handling instead.

## Built-In Middleware Selection

Prefer built-ins before custom middleware.

Use cases:

- `cors_config` for browser-origin policy
- `csrf_config` for CSRF protection
- `AllowedHostsConfig` for host validation
- `compression_config` for gzip or brotli response compression
- `RateLimitConfig` for request throttling
- `LoggingMiddlewareConfig` for request and response logging
- session configs for client-side or server-side sessions

Guidance:

- Keep built-in config explicit and reviewed.
- Use proxy-aware deployment settings for host and client-IP-sensitive middleware like rate limiting.
