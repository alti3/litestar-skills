---
name: routing
description: Design and implement Litestar routing with route decorators, routers, controllers, path/query/header/cookie parameters, and route-level metadata.
---

# Routing

Use this skill when designing endpoint structure, grouping handlers, or fixing route parameter behavior.

## Workflow

1. Start with handler decorators (`@get`, `@post`, etc.).
2. Group related handlers into `Router` or `Controller` units.
3. Validate path parameters and convert types using type hints.
4. Add route-level concerns (`tags`, guards, dependencies) where needed.

## Core Patterns

### Route Handler

```python
from litestar import get

@get("/users/{user_id:int}")
async def get_user(user_id: int) -> dict[str, int]:
    return {"user_id": user_id}
```

### Router

```python
from litestar import Router

user_router = Router(path="/users", route_handlers=[get_user])
```

### Controller

```python
from litestar import Controller, get

class UserController(Controller):
    path = "/users"

    @get("/{user_id:int}")
    async def retrieve(self, user_id: int) -> dict[str, int]:
        return {"user_id": user_id}
```

## Routing Checklist

- Explicitly type path/query/body inputs.
- Prefer routers/controllers for domain grouping.
- Keep handler functions thin; call service layer.
- Apply guards/dependencies at the narrowest useful scope.

## Litestar References

- https://docs.litestar.dev/latest/usage/routing/index.html
- https://docs.litestar.dev/latest/usage/routing/overview.html
- https://docs.litestar.dev/latest/usage/routing/handlers.html
- https://docs.litestar.dev/latest/usage/routing/parameters.html
