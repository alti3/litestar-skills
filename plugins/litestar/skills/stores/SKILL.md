---
name: stores
description: Configure Litestar stores for caching, sessions, and short-lived state with explicit backend selection, namespacing, TTL policy, and failure handling. Use when app features depend on a key-value store lifecycle. Do not use for relational persistence workflows that belong to database layers.
---

# Stores

## Execution Workflow

1. Choose store backend based on durability and latency requirements.
2. Define key schema and namespacing to avoid collisions.
3. Apply TTL policy aligned with product freshness guarantees.
4. Add graceful fallback behavior for transient store outages.

## Implementation Rules

- Keep key naming deterministic and version-safe.
- Separate namespaces by feature and tenant when applicable.
- Avoid storing unbounded payload sizes.
- Treat store values as ephemeral unless durability is guaranteed.

## Example Pattern

```python
# Pseudocode pattern: define namespaced keys + explicit TTL.
session_key = f"session:{user_id}"
await store.set(session_key, value={"uid": user_id}, expires_in=1800)
```

## Validation Checklist

- Confirm TTL expiration behavior matches expectations.
- Confirm key collisions do not occur across features.
- Confirm outage/failure behavior is explicit and tested.

## Cross-Skill Handoffs

- Use `caching` for response-level caching strategy.
- Use `authentication` when session/security data is store-backed.

## Litestar References

- https://docs.litestar.dev/latest/usage/stores.html
- https://docs.litestar.dev/latest/usage/caching.html
