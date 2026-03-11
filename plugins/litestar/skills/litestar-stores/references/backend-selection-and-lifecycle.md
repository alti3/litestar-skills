# Backend Selection And Lifecycle

Use this reference to choose the right Litestar store backend and plan its operational lifecycle.

## `MemoryStore`

Strengths:

- Lowest overhead.
- Simple.
- Good default for local or low-stakes use.

Limits:

- No persistence.
- Not thread-safe.
- Not multiprocess-safe.

Use it when:

- The app is effectively single-process.
- Losing the store contents on restart is acceptable.

Avoid it when:

- Multiple workers or instances must share state.
- Sessions, rate limits, or cache entries must be coherent across processes.

## `FileStore`

Strengths:

- Persistent on disk.
- Easy to back up or inspect externally.
- Supports namespacing through sub-paths.

Limits:

- Slower than memory-backed options.
- Expired data is not proactively swept.
- Requires filesystem-path planning and cleanup routines.

Use it when:

- Data should survive process restart.
- Data volume or longevity matters more than lowest latency.

Operational notes:

- Keys are hashed before becoming file paths.
- `delete_expired()` should be run periodically.
- Startup cleanup is a good pattern for long-lived store directories.

## `RedisStore`

Strengths:

- Good general-purpose production backend.
- Shared across workers and instances.
- Native expiry handling.
- Namespacing support and safe namespace-scoped `delete_all()`.

Use it when:

- The state must be shared.
- Sessions, rate limits, or caches are production concerns.
- One backend should serve multiple isolated logical stores.

Operational notes:

- Default namespace is `LITESTAR`.
- `namespace=None` disables safe namespace bulk delete behavior.
- If you own the Redis client externally, you also own its shutdown unless configured otherwise.

## `ValkeyStore`

Guidance:

- Treat it like `RedisStore` for Litestar store design.
- The Litestar docs state Redis notes apply to Valkey as well.

## Unsupported Memcached Note

- Litestar docs explicitly call out Memcached as unsupported.
- The stated reasons include missing expiry inspection and lack of Redis-style scanning needed for safe pattern-based deletion.

Practical rule:

- Do not design around Memcached as if it were a first-class Litestar store backend.
