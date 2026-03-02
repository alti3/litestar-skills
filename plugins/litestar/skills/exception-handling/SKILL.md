---
name: exception-handling
description: Implement robust Litestar exception handling with custom exception classes, handler mapping, and consistent API error contracts.
---

# Exception Handling

Use this skill when defining API error contracts and mapping domain failures to HTTP responses.

## Workflow

1. Define domain exceptions for expected failure classes.
2. Map exceptions to Litestar handlers globally or by scope.
3. Return consistent error payload shapes.
4. Log with enough context for debugging without leaking sensitive details.

## Pattern

```python
from litestar import Litestar, Request
from litestar.response import Response


class DomainError(Exception):
    pass


def domain_error_handler(_: Request, __: DomainError) -> Response[dict[str, str]]:
    return Response({"error": "domain_error"}, status_code=400)


app = Litestar(
    route_handlers=[],
    exception_handlers={DomainError: domain_error_handler},
)
```

## Error Handling Checklist

- Distinguish client errors (4xx) from server errors (5xx).
- Keep payload structure stable (`code`, `message`, optional `details`).
- Pair exception mapping with tests for each expected failure mode.

## Litestar References

- https://docs.litestar.dev/latest/usage/exceptions.html
