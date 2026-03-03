---
name: litestar-dependency-injection
description: Apply Litestar dependency injection with Provide, layered dependency scopes, overrides, and lifecycle-aware service wiring. Use when handlers/controllers/routers require shared services, repositories, settings, or per-request resources. Do not use when simple local function parameters are sufficient.
---

# Dependency Injection

## Execution Workflow

1. Define provider callables with clear ownership and side-effect boundaries.
2. Register dependencies at the narrowest effective scope (app/router/controller/handler).
3. Inject only stable contracts (protocols/services), not transport-layer internals.
4. Add override paths for tests and special runtime contexts.

## Implementation Rules

- Use consistent dependency keys (`settings`, `db_session`, `current_user`).
- Keep provider setup idempotent and explicit about lifecycle.
- Avoid hidden global state and implicit singleton mutation.
- Prefer provider composition over deep nested dependency trees.

## Example Pattern

```python
from litestar import Litestar, get
from litestar.di import Provide


def provide_settings() -> dict[str, str]:
    return {"env": "dev"}

@get("/env")
async def read_env(settings: dict[str, str]) -> dict[str, str]:
    return settings

app = Litestar(
    route_handlers=[read_env],
    dependencies={"settings": Provide(provide_settings)},
)
```

## Validation Checklist

- Confirm dependency resolution order and scope precedence are correct.
- Confirm overrides work in tests without monkeypatching internals.
- Confirm request-scoped resources are cleaned up correctly.

## Cross-Skill Handoffs

- Use `litestar-databases` for session/unit-of-work provisioning.
- Use `litestar-testing` for dependency override patterns.

## Litestar References

- https://docs.litestar.dev/latest/usage/dependency-injection.html
- https://docs.litestar.dev/latest/usage/applications.html
