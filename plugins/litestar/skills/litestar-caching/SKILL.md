---
name: litestar-caching
description: Configure Litestar response caching with route-level cache controls, key design, TTL strategy, and invalidation-aware behavior. Use when optimizing read-heavy endpoints or reducing repeated computation. Do not use for mutable workflows that require immediate consistency unless explicit cache invalidation is designed.
---

# Caching

## Execution Workflow

1. Select cache candidates (idempotent, deterministic read endpoints).
2. Set route cache TTL and define key dimensions (tenant, locale, auth context) when needed.
3. Identify invalidation triggers from write paths and data-refresh events.
4. Validate cache correctness under concurrency and stale data windows.

## Implementation Rules

- Cache only responses that are safe to replay.
- Keep TTL explicit and document freshness expectations.
- Avoid caching personalized/authenticated responses unless keys fully partition user context.
- Treat cache entries as derived data, not source of truth.

## Example Pattern

```python
from litestar import get

@get("/articles", cache=60)
async def list_articles() -> list[dict[str, str]]:
    return [{"title": "example"}]
```

## Validation Checklist

- Confirm cache hits and misses behave as expected.
- Confirm stale data windows are acceptable for product requirements.
- Confirm writes invalidate or bypass stale entries correctly.
- Confirm no cross-tenant or cross-user cache leakage.

## Cross-Skill Handoffs

- Use `stores` for backend/TTL policy details.
- Use `responses` when response metadata affects caching behavior.

## Litestar References

- https://docs.litestar.dev/latest/usage/caching.html
- https://docs.litestar.dev/latest/usage/responses.html
