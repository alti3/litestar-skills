---
name: stores
description: Configure Litestar stores for caching/session/state-like persistence concerns with explicit TTL, namespace, and lifecycle control.
---

# Stores

Use this skill when wiring store backends for cache/session or ephemeral state.

## Workflow

1. Choose a backend based on durability and latency requirements.
2. Define key namespace and TTL strategy.
3. Integrate store usage in handlers/services.
4. Validate expiration and failure behavior.

## Litestar References

- https://docs.litestar.dev/latest/usage/stores.html
