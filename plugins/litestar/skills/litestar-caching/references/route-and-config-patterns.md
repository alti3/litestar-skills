# Route And Config Patterns

## Table of Contents

- Route-level `cache` modes
- App-level `ResponseCacheConfig`
- Store selection and shared-cache wiring
- Route-level key-builder overrides

## Route-Level `cache` Modes

Litestar route handlers accept a `cache` argument with three useful modes:

- `cache=True`: use `ResponseCacheConfig.default_expiration`
- `cache=<seconds>`: use a route-specific TTL
- `cache=CACHE_FOREVER`: store indefinitely

### `cache=True`

```python
from litestar import get


@get("/articles", cache=True)
async def list_articles() -> list[dict[str, str]]:
    return [{"title": "Caching in Litestar"}]
```

Guidance:

- Use this when the app-wide default TTL is already correct.
- Be explicit about `default_expiration` at app construction so `cache=True` is predictable.
- Per the docs, if `default_expiration=None`, `cache=True` keeps entries indefinitely.

### Route-Specific TTL

```python
from litestar import get


@get("/exchange-rates", cache=30)
async def exchange_rates() -> dict[str, float]:
    return {"USD": 1.0, "EUR": 0.92}
```

Guidance:

- Prefer explicit per-route TTLs when freshness differs materially from the app default.
- Keep TTL short for mutable data and longer for slow-changing catalog or config data.

### `CACHE_FOREVER`

```python
from litestar import get
from litestar.config.response_cache import CACHE_FOREVER


@get("/assets/version-manifest", cache=CACHE_FOREVER)
async def asset_manifest() -> dict[str, str]:
    return {"app.js": "app.4b0fd6.js"}
```

Guidance:

- Reserve this for immutable payloads or version-addressed resources.
- If the data can change, pair forever-caching with key versioning or explicit deletes.

## App-Level `ResponseCacheConfig`

`ResponseCacheConfig` sets the defaults Litestar uses when a route opts into caching.

```python
from litestar import Litestar, get
from litestar.config.response_cache import ResponseCacheConfig


@get("/catalog", cache=True)
async def catalog() -> list[dict[str, str]]:
    return [{"sku": "SKU-001", "name": "Starter Kit"}]


app = Litestar(
    route_handlers=[catalog],
    response_cache_config=ResponseCacheConfig(default_expiration=300),
)
```

Important fields from the reference docs:

- `default_expiration`: used by handlers configured with `cache=True`
- `key_builder`: global cache key builder
- `store`: name of the store to use
- `cache_response_filter`: predicate deciding whether a response should be written to cache

Guidance:

- Set `default_expiration` explicitly instead of relying on the library default in high-signal codebases.
- Treat app-level config as the baseline and use route overrides only when one endpoint truly differs.

## Store Selection And Shared-Cache Wiring

The usage docs state that Litestar uses `MemoryStore` by default. For multi-instance deployments, point response caching at a shared store.

```python
import asyncio

from litestar import Litestar, get
from litestar.config.response_cache import ResponseCacheConfig
from litestar.stores.redis import RedisStore


@get("/analytics/summary", cache=60)
async def analytics_summary() -> dict[str, int]:
    await asyncio.sleep(1)
    return {"active_users": 128}


redis_store = RedisStore.with_client(url="redis://localhost/", port=6379, db=0)

app = Litestar(
    route_handlers=[analytics_summary],
    stores={"redis_backed_store": redis_store},
    response_cache_config=ResponseCacheConfig(
        default_expiration=60,
        store="redis_backed_store",
    ),
)
```

Guidance:

- `MemoryStore` is process-local. It will not share entries across workers or instances.
- Use a named store so the cache backend is explicit in app construction.
- Coordinate store choice with `litestar-stores` when failure handling, TTL strategy, or key namespaces matter beyond response caching.

## Route-Level Key-Builder Overrides

When one route needs special key dimensions, override the key builder on that route instead of changing the whole app.

```python
from litestar import Litestar, Request, get


def preview_key_builder(request: Request) -> str:
    preview = request.query_params.get("preview", "0")
    locale = request.headers.get("x-locale", "en")
    return f"{request.method}:{request.url.path}:preview={preview}:locale={locale}"


@get("/pages/home", cache=120, cache_key_builder=preview_key_builder)
async def page_home() -> dict[str, str]:
    return {"title": "Home"}


app = Litestar(route_handlers=[page_home])
```

Guidance:

- Use route-level overrides for isolated exceptions, not as the default habit.
- Include only inputs that actually shape the response, but include all of them.
