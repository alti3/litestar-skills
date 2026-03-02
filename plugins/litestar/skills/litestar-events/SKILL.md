---
name: litestar-events
description: Use Litestar startup/shutdown event hooks and lifecycle orchestration to initialize shared resources and perform graceful cleanup. Use when app-wide resources must be created or released at lifecycle boundaries. Do not use for request-scoped behavior that belongs in middleware or dependencies.
---

# Events

## Execution Workflow

1. Identify resources that require startup initialization and shutdown cleanup.
2. Register startup and shutdown hooks with explicit ordering dependencies.
3. Keep hooks idempotent and failure-aware.
4. Expose initialized resources via app state or dependencies.

## Implementation Rules

- Fail fast on critical startup failures.
- Avoid long blocking calls in lifecycle hooks.
- Ensure cleanup always runs for external resources (DB pools, clients, queues).
- Keep side effects observable through logs/metrics.

## Example Pattern

```python
from litestar import Litestar

async def on_startup() -> None:
    ...

async def on_shutdown() -> None:
    ...

app = Litestar(
    route_handlers=[...],
    on_startup=[on_startup],
    on_shutdown=[on_shutdown],
)
```

## Validation Checklist

- Confirm startup creates required resources exactly once.
- Confirm shutdown releases resources even after runtime failures.
- Confirm app behavior is deterministic across restart cycles.

## Cross-Skill Handoffs

- Use `lifecycle-hooks` for request/response lifecycle instrumentation.
- Use `app-setup` when refactoring overall startup composition.

## Litestar References

- https://docs.litestar.dev/latest/usage/events.html
- https://docs.litestar.dev/latest/usage/applications.html
