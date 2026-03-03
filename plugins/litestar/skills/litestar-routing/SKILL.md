---
name: litestar-routing
description: Design and implement Litestar routing with handlers, routers, controllers, path design, parameter typing, and route-level metadata/dependencies. Use when creating or refactoring endpoint topology and URL contracts. Do not use for purely internal service logic unrelated to HTTP route structure.
---

# Routing

## Execution Workflow

1. Define endpoint contracts with handler decorators and typed parameters.
2. Group related endpoints into routers or controllers.
3. Apply route-level metadata (tags, dependencies, guards, response config) intentionally.
4. Validate path matching, precedence, and parameter parsing behavior.

## Implementation Rules

- Keep URL design stable, resource-oriented, and version-aware.
- Keep handlers thin; delegate business logic to services.
- Use explicit path converters and narrow parameter types.
- Apply dependencies and guards at the narrowest effective scope.

## Example Pattern

```python
from litestar import Router, get

@get("/{user_id:int}")
async def get_user(user_id: int) -> dict[str, int]:
    return {"user_id": user_id}

user_router = Router(path="/users", route_handlers=[get_user])
```

## Validation Checklist

- Confirm route registration and conflict resolution behave as expected.
- Confirm parameter coercion/validation aligns with declared types.
- Confirm route-level metadata appears correctly in generated schema/docs.

## Cross-Skill Handoffs

- Use `litestar-requests` and `litestar-responses` for transport contract depth.
- Use `litestar-authentication` and `litestar-dependency-injection` for route-scoped security/services.

## Litestar References

- https://docs.litestar.dev/latest/usage/routing/index.html
- https://docs.litestar.dev/latest/usage/routing/overview.html
- https://docs.litestar.dev/latest/usage/routing/handlers.html
- https://docs.litestar.dev/latest/usage/routing/parameters.html
