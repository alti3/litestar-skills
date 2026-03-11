# Store Operations And Data

This reference covers the common Litestar store contract and the operational consequences of that abstraction.

## Core Async Operations

- `set(key, value, expires_in=None)`
- `get(key, renew_for=None)`
- `delete(key)`
- `delete_all()`
- `exists(key)`
- `expires_in(key)`

## Method Semantics

### `set()`

- Accepts a string key.
- Accepts bytes or string values.
- `expires_in` can be an integer number of seconds, a `timedelta`, or `None`.

Design implication:

- Set TTL at write time when absolute expiry matters.

### `get()`

- Returns bytes or `None`.
- `renew_for` can extend an existing TTL when the stored value already had one.

Design implication:

- Use `renew_for` for sliding-expiration behavior such as server-side sessions or access-renewed caches.

### `delete()`

- Deletes a key if present.
- Missing keys are a no-op.

### `delete_all()`

- Bulk-clears the store or namespace.
- This is only safe when store boundaries or namespaces are well designed.

### `exists()` and `expires_in()`

- Use `exists()` for explicit presence checks instead of inferring from payload semantics.
- Use `expires_in()` when code or tests need to assert remaining TTL.

## Data Contract

- The interchangeable store contract is bytes-oriented.
- Strings are UTF-8 encoded on write.
- Reads still return bytes even when the original write used a string.

Practical rule:

- Serialize structured values yourself when backend portability matters.

## MemoryStore Caveat

- `MemoryStore` can technically hold arbitrary Python objects because it stores in memory without the same encoding boundary.
- Litestar does not guarantee that behavior at the abstract store level.

Practical rule:

- Do not build production designs that depend on arbitrary-object storage if a future backend swap is possible.

## TTL and Cleanup

- Backend implementations differ in how expired data is removed.
- Redis/Valkey use native expiry.
- `MemoryStore` and `FileStore` may retain expired entries until access or explicit cleanup.

Practical rule:

- Distinguish "expired for reads" from "physically removed from storage."

## Renewal On Access

- `get(..., renew_for=...)` resets TTL only for values that already had an expiry.
- This is the right fit for session-like state that should stay alive while active.

Testing focus:

- Test both initial expiry and renewal behavior, not only one or the other.
