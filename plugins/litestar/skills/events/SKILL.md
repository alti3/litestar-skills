---
name: events
description: Use Litestar lifecycle events and listeners for startup/shutdown initialization, cleanup, and event-driven application behavior.
---

# Events

Use this skill when code must run during application startup/shutdown or when lifecycle orchestration is needed.

## Workflow

1. Register startup hooks for shared resources (DB pools, clients, caches).
2. Register shutdown hooks for cleanup.
3. Keep hooks idempotent and failure-aware.
4. Use app state/dependencies to expose initialized resources.

## Pattern

```python
from litestar import Litestar


async def on_startup() -> None:
    pass


async def on_shutdown() -> None:
    pass


app = Litestar(
    route_handlers=[],
    on_startup=[on_startup],
    on_shutdown=[on_shutdown],
)
```

## Event Checklist

- Fail fast on critical startup failures.
- Ensure shutdown paths release external resources.
- Avoid long blocking tasks in lifecycle hooks.

## Litestar References

- https://docs.litestar.dev/latest/usage/events.html
