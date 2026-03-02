---
name: caching
description: Add and tune Litestar response caching with route-level cache controls, cache-key strategy, and invalidation-aware API behavior.
---

# Caching

Use this skill when endpoints need read-performance improvements and predictable cache behavior.

## Workflow

1. Identify idempotent read endpoints (`GET`) suitable for caching.
2. Enable route-level caching with finite TTL.
3. Add a stable cache-key strategy when request context affects output.
4. Verify invalidation expectations against write endpoints.

## Core Pattern

```python
from litestar import get

@get("/articles", cache=60)
async def list_articles() -> list[dict[str, str]]:
    return [{"title": "example"}]
```

## Strategy Notes

- Cache only safe, deterministic responses.
- Include tenant/user/locale dimensions in key building when applicable.
- Keep TTL short for frequently changing resources.
- Do not cache authenticated responses unless keying is strict and intentional.

## Litestar References

- https://docs.litestar.dev/latest/usage/caching.html
- https://docs.litestar.dev/latest/usage/responses.html#response-caching
