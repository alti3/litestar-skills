---
name: litestar-middleware
description: Design and apply Litestar middleware for cross-cutting concerns such as CORS, CSRF, allowed-host checks, compression, rate limiting, logging, sessions, request enrichment, policy enforcement, and custom ASGI pipeline control. Use when behavior must wrap broad route sets consistently. Do not use for route-specific business rules that belong in handlers or services.
---

# Middleware

Use this skill when request/response flow must be intercepted across app/router/controller/handler layers.

## Execution Workflow

1. Confirm whether the requirement is middleware-appropriate (cross-cutting ASGI flow concern, not route business logic).
2. Prefer built-in middleware/config objects first (`cors_config`, `csrf_config`, `compression_config`, `RateLimitConfig`, `LoggingMiddlewareConfig`, session configs, `AllowedHostsConfig`).
3. Choose the correct layer for attachment (application, router, controller, handler).
4. Validate call order and exclusions (`opt`, path patterns, scope type) before rollout.
5. For custom middleware, choose implementation style:
6. Function factory for simple wrappers.
7. `ASGIMiddleware` (recommended) for configurable production middleware.
8. `MiddlewareProtocol` for minimal custom behavior.
9. `AbstractMiddleware` when migrating/maintaining legacy style.
10. Validate behavior on normal responses and exception-generated responses.

## Implementation Rules

- Keep middleware focused on one cross-cutting responsibility.
- Avoid placing domain business logic in middleware.
- Keep middleware non-blocking and scope-aware (`http`, `websocket`, `lifespan` as applicable).
- Use built-in config middleware whenever available before creating custom implementations.
- Treat middleware order as part of API behavior; document ordering assumptions.
- Use lifecycle hooks (`after_request`, `before_send`) when you need response-object mutation rather than raw ASGI message mutation.

## Middleware Fundamentals

- Middleware is any callable that accepts at least an `app` kwarg and returns an `ASGIApp`.
- The injected `app` is the next ASGI app in the chain, not the `Litestar` application object itself.
- Middleware can be declared at any layer in Litestar’s layered architecture.

Basic factory form:

```python
from litestar import Litestar
from litestar.types import ASGIApp, Receive, Scope, Send

def middleware_factory(app: ASGIApp) -> ASGIApp:
    async def my_middleware(scope: Scope, receive: Receive, send: Send) -> None:
        await app(scope, receive, send)
    return my_middleware

app = Litestar(route_handlers=[...], middleware=[middleware_factory])
```

## Middleware Call Order and Exceptions

Call order rules:

- Within each layer, middleware execute in the order they are listed.
- Across layers, traversal follows application -> router -> controller -> handler.

Exception behavior:

- Exceptions from handlers/dependencies that are transformed into responses still pass through middleware.
- `NotFoundException` and `MethodNotAllowedException` are raised by the ASGI router before the middleware stack; handle these at app-layer exception handling if customization is needed.

## Built-in Middleware Coverage

### CORS

- Configure with `CORSConfig` via `Litestar(..., cors_config=...)`.
- Use this for browser-origin policy control instead of manual header middleware.

### CSRF

- Configure with `CSRFConfig` via `Litestar(..., csrf_config=...)`.
- Safe-method requests establish token cookie; unsafe methods must echo token via header or form data.
- Exclude routes via handler opts (for example, `exclude_from_csrf=True`) or CSRF config `exclude` patterns.

### Allowed Hosts

- Configure host restrictions using `AllowedHostsConfig` (or host domain list) to enforce `Host` / `X-Forwarded-Host` policy.
- Use when deploying behind public ingress where host-header validation is required.

### Compression

- Configure with `CompressionConfig` via `compression_config`.
- Supports `gzip` and `brotli` backends.
- Key controls include size thresholds and backend-specific compression knobs (`gzip_compress_level`, `brotli_quality`, `brotli_mode`, `brotli_lgwin`, `brotli_lgblock`, fallback behavior).

### Rate limiting

- Configure with `RateLimitConfig`, including required `rate_limit=(unit, quota)`.
- Supports exclusion patterns (for example, excluding schema routes).
- Behind proxies, use trusted proxy middleware (for example Uvicorn/Hypercorn proxy middleware) to set client address safely.

### Logging middleware

- Configure using `LoggingMiddlewareConfig` plus app `logging_config`.
- Supports request/response logging with obfuscation controls for sensitive headers/cookies.
- By default it obfuscates `Authorization`, `X-API-KEY`, and `session` cookie.
- Compressed response bodies are omitted from logging unless explicitly enabled via `include_compressed_body=True` and body logging fields.

### Session middleware

- Litestar session middleware supports client-side and server-side sessions.
- Client-side: `CookieBackendConfig` (cookie-backed encrypted payload, requires `cryptography` extra).
- Server-side: `ServerSideSessionConfig` with configured `stores["sessions"]` backend.
- Both modes share core cookie configuration concepts via backend config base.

## Creating Custom Middleware

### Recommended: `ASGIMiddleware`

- Prefer extending `ASGIMiddleware` for new custom middleware.
- Implement `handle(scope, receive, send, next_app)`.
- Supports skip controls:
- `scopes` for scope-type filtering.
- `exclude_path_pattern` for path exclusions.
- `exclude_opt_key` for route `opt`-based exclusions.
- Supports explicit constructor arguments for middleware configuration.

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

### Minimal protocol: `MiddlewareProtocol`

- Protocol requires:
- `__init__(self, app: ASGIApp, **kwargs)`
- `__call__(self, scope, receive, send)`
- Useful for lightweight wrappers and early-return responses (for example redirects).
- If mutating incoming request data, modify ASGI `scope` (source of truth), not transient request objects.
- To mutate outgoing ASGI response messages, wrap `send` and inspect `message["type"]`.

### Legacy support: `AbstractMiddleware`

- `AbstractMiddleware` can be subclassed and supports class attributes such as `scopes`, `exclude`/path exclusions, and `exclude_opt_key`.
- Prefer `ASGIMiddleware` for new code; keep `AbstractMiddleware` mainly for compatibility/migration scenarios.

### Passing args with `DefineMiddleware`

- `DefineMiddleware` wraps a middleware callable plus `*args`/`**kwargs`.
- Useful when middleware is implemented as a factory needing runtime options.

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

## Validation Checklist

- Confirm middleware is attached on the intended layer(s) only.
- Confirm call order matches declared layer and list order.
- Confirm exclusions via `exclude_path_pattern` / `exclude_opt_key` behave as expected.
- Confirm behavior for both success and exception-generated responses.
- Confirm router-level `404/405` handling expectations (pre-middleware exceptions) are met.
- Confirm custom middleware remains ASGI-compliant and non-blocking.
- Confirm request/response mutation occurs at the right stage (`scope` vs ASGI `send` vs lifecycle hooks).
- Confirm built-in security middleware settings (CORS/CSRF/allowed hosts/rate limit) align with deployment topology.
- Confirm session middleware backend (client vs server) and secret/store configuration are production-safe.
- Confirm logging middleware obfuscation and compressed-body behavior match security requirements.

## Cross-Skill Handoffs

- Use `litestar-lifecycle-hooks` for hook-stage logic rather than ASGI wrapping.
- Use `litestar-authentication`, `litestar-logging`, and `litestar-metrics` for domain-specific middleware outcomes.
- Use `litestar-security` for full defense-in-depth policy across middleware, auth backends, and route guards.
- Use `litestar-routing` when middleware behavior depends on route layering and `opt` metadata strategy.

## Litestar References

- https://docs.litestar.dev/latest/usage/middleware/index.html
- https://docs.litestar.dev/latest/usage/middleware/using-middleware.html
- https://docs.litestar.dev/latest/usage/middleware/builtin-middleware.html
- https://docs.litestar.dev/latest/usage/middleware/creating-middleware.html
