---
name: advanced-alchemy-caching
description: Design cache-aware Advanced Alchemy usage, including deterministic read paths, SQLAlchemy statement-cache-safe custom type configuration, and framework-level response caching around repository and service queries. Use when repeated read workloads need performance tuning without corrupting data semantics, or when custom types or filters interfere with cacheability. Do not use as a substitute for correctness in repository or service design.
---

# Caching

## Execution Workflow

1. Identify deterministic read paths in repositories or services before adding any caching layer.
2. Keep query filters and loader options stable so identical reads stay cacheable.
3. For custom SQLAlchemy types, ensure constructor state is hashable and safe for statement caching.
4. Use framework-level response caching only for read paths with explicit freshness and invalidation expectations.
5. Revisit write paths so updates invalidate, bypass, or tolerate stale cached reads.

## Implementation Rules

- Treat caches as derived data, never as the source of truth.
- Avoid caching reads that depend on implicit session state or nondeterministic defaults.
- Do not enable cacheable custom types unless their public constructor state is stable and hashable.
- Separate SQLAlchemy statement caching concerns from HTTP response caching concerns.

## Example Pattern

```python
class LookupType(TypeDecorator):
    cache_ok = True

    def __init__(self, lookup: dict[str, int]) -> None:
        self._lookup = lookup
        self.lookup = tuple((key, lookup[key]) for key in sorted(lookup))
```

## Validation Checklist

- Confirm repeated queries actually generate stable SQL and parameters.
- Confirm custom types do not emit SQLAlchemy cache warnings.
- Confirm cached responses are invalidated or freshness-bounded after writes.
- Confirm no personalized or tenant-specific data leaks across cache keys.

## Cross-Skill Handoffs

- Use `advanced-alchemy-repositories` and `advanced-alchemy-services` to make read paths deterministic first.
- Use `advanced-alchemy-types` when cacheability problems come from custom types.
- Use `litestar-caching` if a Litestar app needs route-level response caching above Advanced Alchemy.

## Advanced Alchemy References

- https://advanced-alchemy.litestar.dev/latest/usage/caching.html
- https://docs.advanced-alchemy.litestar.dev/latest/reference/types.html
