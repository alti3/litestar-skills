---
name: exception-handling
description: Implement Litestar exception mapping with custom exception classes, scoped handlers, and stable API error contracts. Use when defining deterministic error responses and translating domain failures to HTTP semantics. Do not use for authentication/authorization policy decisions that belong in security layers.
---

# Exception Handling

## Execution Workflow

1. Define domain exception classes for expected business failures.
2. Map exceptions to HTTP responses at the appropriate scope.
3. Enforce a stable error payload schema (`code`, `message`, optional `details`).
4. Log failures with actionable context while redacting sensitive data.

## Implementation Rules

- Distinguish client-caused (`4xx`) from server-caused (`5xx`) failures.
- Keep exception handlers pure and predictable.
- Avoid broad catch-all handlers that hide root causes.
- Make error codes machine-friendly and version stable.

## Example Pattern

```python
from litestar import Litestar, Request
from litestar.response import Response

class DomainError(Exception):
    pass

def domain_error_handler(_: Request, __: DomainError) -> Response[dict[str, str]]:
    return Response({"code": "domain_error", "message": "invalid operation"}, status_code=400)

app = Litestar(route_handlers=[...], exception_handlers={DomainError: domain_error_handler})
```

## Validation Checklist

- Confirm each expected exception class maps to the intended status code.
- Confirm payload shape is consistent across handlers/routes.
- Confirm unhandled exceptions still surface appropriately for observability.

## Cross-Skill Handoffs

- Use `authentication` for auth-specific errors and challenge responses.
- Use `responses` for shared response envelope conventions.
- Use `testing` for exhaustive failure-path assertions.

## Litestar References

- https://docs.litestar.dev/latest/usage/exceptions.html
- https://docs.litestar.dev/latest/usage/responses.html
