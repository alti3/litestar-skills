# Key Builder And Invalidation

## Table of Contents

- Default key-builder behavior
- Safe custom key builders
- Tenant, locale, and auth partitioning
- Invalidation and versioning strategy

## Default Key-Builder Behavior

The usage docs describe the default cache key as path plus sorted query params. The API reference is slightly more specific: `default_cache_key_builder()` combines the request method and path with sorted query params.

Practical takeaway:

- Distinct query parameter orders still map to the same key.
- `GET /items?page=1&sort=name` and `GET /items?sort=name&page=1` should share a key.
- If the payload also varies by headers, cookies, or user identity, the default key builder is not sufficient.

## Safe Custom Key Builders

Use a custom key builder when the response depends on anything outside the default dimensions.

```python
from litestar import Litestar, Request
from litestar.config.response_cache import ResponseCacheConfig


def tenant_locale_key_builder(request: Request) -> str:
    tenant_id = request.headers.get("x-tenant-id", "public")
    locale = request.headers.get("accept-language", "en")
    preview = request.query_params.get("preview", "0")
    return (
        f"{request.method}:{request.url.path}"
        f":tenant={tenant_id}"
        f":locale={locale}"
        f":preview={preview}"
    )


app = Litestar(
    route_handlers=[...],
    response_cache_config=ResponseCacheConfig(
        default_expiration=120,
        key_builder=tenant_locale_key_builder,
    ),
)
```

Guidance:

- Keep the function pure and deterministic.
- Avoid timestamps, randomness, or mutable globals.
- Normalize optional inputs so equivalent requests map to the same key.
- Use stable string formats that are easy to reproduce in tests and invalidation code.

## Tenant, Locale, And Auth Partitioning

Before enabling caching, ask what makes one caller's response different from another's.

Common key dimensions:

- tenant or account ID
- authenticated user ID when the payload is personalized
- permission or role scope when access changes fields or related objects
- locale or market
- preview, feature-flag, or experiment bucket
- explicit representation controls such as a query parameter

Unsafe pattern:

```python
from litestar import get


@get("/me", cache=300)
async def current_user_profile() -> dict[str, str]:
    return {"name": "depends on authenticated user"}
```

Why it is unsafe:

- The default key builder does not know which user is calling.
- Two different authenticated users could otherwise collide.

Safer direction:

- Either do not cache the route.
- Or include the user identity or permission partition in a custom key builder.

## Invalidation And Versioning Strategy

Inference from the docs:

- Litestar's caching docs cover route enablement, TTL, key building, store selection, and response-write filtering.
- They do not describe automatic cache invalidation tied to domain writes.

Design implication:

- Treat invalidation as an application concern.

Preferred strategies:

- Short TTL for frequently changing data.
- Explicit store deletion when you can reproduce the exact key.
- Versioned keys when invalidating a family of entries is simpler than deleting each one.

### Versioned Key Pattern

```python
from litestar import Request


def versioned_catalog_key_builder(request: Request) -> str:
    version = getattr(request.app.state, "catalog_cache_version", "v1")
    category = request.query_params.get("category", "all")
    return f"{version}:{request.method}:{request.url.path}:category={category}"
```

Guidance:

- Bump the version when writes make an entire class of cached responses stale.
- For distributed deployments, keep the version source in shared state or shared storage, not only in process memory.
- `app.state` is acceptable for demos or single-process tests, but not a complete distributed invalidation solution by itself.

### Explicit Delete Pattern

If you must delete a cache entry directly, use the same key-building rules the cached route uses. Keep the key format centralized so write paths and read paths cannot drift apart.
