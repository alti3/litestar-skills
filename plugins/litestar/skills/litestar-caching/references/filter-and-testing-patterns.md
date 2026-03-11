# Filter And Testing Patterns

## Table of Contents

- `cache_response_filter` basics
- Useful filter patterns
- Testing cache hits and misses

## `cache_response_filter` Basics

`cache_response_filter` is configured on `ResponseCacheConfig`. It receives the HTTP scope and status code, then returns a boolean indicating whether Litestar should store the response.

```python
from litestar import Litestar
from litestar.config.response_cache import ResponseCacheConfig
from litestar.types import HTTPScope


def cache_only_successes(_: HTTPScope, status_code: int) -> bool:
    return 200 <= status_code < 300


app = Litestar(
    route_handlers=[...],
    response_cache_config=ResponseCacheConfig(
        default_expiration=60,
        cache_response_filter=cache_only_successes,
    ),
)
```

Guidance:

- Use the filter to decide whether a response should be written, not to partition users or tenants.
- Keep the predicate cheap and easy to reason about.
- Default to caching only successful responses unless you intentionally want to cache something else.

## Useful Filter Patterns

### Cache Only Successful `GET` Responses

```python
from litestar.types import HTTPScope


def cache_only_successful_gets(scope: HTTPScope, status_code: int) -> bool:
    return scope["method"] == "GET" and 200 <= status_code < 300
```

Use this when:

- the app should be conservative by default
- only standard read endpoints should populate the cache

### Avoid Caching Certain Statuses

```python
from litestar.types import HTTPScope


def avoid_redirects_and_errors(_: HTTPScope, status_code: int) -> bool:
    return status_code not in {301, 302, 307, 308, 401, 403, 404, 500}
```

Use this when:

- redirects or auth failures should never be replayed from cache
- negative caching would be misleading or too sticky for clients

## Testing Cache Hits And Misses

A cache test should prove both that equivalent requests reuse the cached response and that materially different requests do not.

```python
from litestar import get
from litestar.testing import create_test_client


call_count = {"value": 0}


@get("/expensive", cache=60)
def expensive() -> dict[str, int]:
    call_count["value"] += 1
    return {"calls": call_count["value"]}


with create_test_client(route_handlers=[expensive]) as client:
    first = client.get("/expensive")
    second = client.get("/expensive")

    assert first.status_code == 200
    assert second.status_code == 200
    assert first.json() == {"calls": 1}
    assert second.json() == {"calls": 1}
```

Also test isolation:

- Different query strings that should produce different payloads
- Different tenant or auth identities when the key builder includes them
- Responses that should not be cached because the filter rejected them

Example miss caused by different query params:

```python
from litestar import Request, get
from litestar.testing import create_test_client


@get("/search", cache=60)
def search(request: Request) -> dict[str, str]:
    term = request.query_params["q"]
    return {"term": term}


with create_test_client(route_handlers=[search]) as client:
    assert client.get("/search?q=litestar").json() == {"term": "litestar"}
    assert client.get("/search?q=cache").json() == {"term": "cache"}
```

Guidance:

- Keep cache tests deterministic and local.
- Assert both the HTTP response and the side effect proving whether the handler re-executed.
- Add targeted tests for the custom key builder whenever the response varies by tenant, locale, or auth context.
