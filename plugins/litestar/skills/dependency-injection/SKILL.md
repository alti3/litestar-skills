---
name: dependency-injection
description: Apply Litestar dependency injection using Provide, scoped dependencies, and clean service wiring for handlers, controllers, and routers.
---

# Dependency Injection

Use this skill when handlers need shared services, repositories, config, or request-scoped resources.

## Workflow

1. Define provider functions and wrap them with `Provide`.
2. Register dependencies at app/router/controller/handler scope.
3. Prefer narrow scope for overrides and testability.
4. Keep service lifecycle explicit (singleton vs request-scoped behavior).

## Core Pattern

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

## DI Checklist

- Use clear dependency keys (`settings`, `db_session`, `current_user`).
- Keep provider side effects controlled.
- Override dependencies in tests rather than monkeypatching internals.

## Litestar References

- https://docs.litestar.dev/latest/usage/dependency-injection.html
