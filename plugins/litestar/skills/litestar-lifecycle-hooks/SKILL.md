---
name: litestar-lifecycle-hooks
description: Implement Litestar lifecycle hooks for request/response interception, cross-cutting policies, and lightweight instrumentation around handler execution. Use when logic must run before or after handler processing. Do not use for global resource bootstrapping that belongs to startup/shutdown events or for the in-process event bus handled by `litestar-events`.
---

# Lifecycle Hooks

## Execution Workflow

1. Choose the exact lifecycle stage needed for behavior injection.
2. Keep hook logic deterministic and focused on cross-cutting concerns.
3. Compose hook behavior with middleware order and exception handling.
4. Verify hook side effects are observable and testable.

## Implementation Rules

- Keep hooks lightweight to avoid latency inflation.
- Avoid embedding domain business rules in hooks.
- Make ordering dependencies explicit when multiple hooks interact.
- Ensure hook errors are handled without masking root cause.
- Do not substitute hooks for event emission when multiple decoupled side effects should react to one domain action.

## Example Pattern

```python
# Pseudocode pattern: attach lifecycle hooks for cross-cutting behavior.
from litestar import Litestar

app = Litestar(
    route_handlers=[...],
    before_send=[...],
    after_exception=[...],
)
```

## Validation Checklist

- Confirm hook execution order matches design.
- Confirm hooks run for both success and error paths where intended.
- Confirm instrumentation and policy side effects are deterministic.

## Cross-Skill Handoffs

- Use `litestar-app-setup` for startup/shutdown hooks, lifespan, and application resource ownership.
- Use `litestar-events` for decoupled in-process side effects with listeners and `app.emit(...)`.
- Use `litestar-middleware` for ASGI-wide policies that should wrap the whole pipeline.

## Litestar References

- https://docs.litestar.dev/latest/usage/lifecycle-hooks.html
- https://docs.litestar.dev/latest/usage/middleware/index.html
