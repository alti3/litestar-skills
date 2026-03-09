---
name: advanced-alchemy-routing
description: Implement Advanced Alchemy-backed CRUD routing patterns with separate read and write contracts, pagination filters, repository-only versus service-backed handlers, and predictable endpoint composition. Use when exposing Advanced Alchemy models over HTTP in Litestar, FastAPI, or Flask, especially for list/detail/create/update/delete flows. Do not use for low-level database setup or model design.
---

# Routing

## Execution Workflow

1. Decide whether the endpoint layer should be service-backed or repository-only.
2. Separate read schemas from write schemas when API contracts differ from the ORM model.
3. Standardize collection routes around filtering and `LimitOffset` pagination.
4. Keep item routes explicit for get, patch, and delete, including typed identifiers.
5. Commit writes through the framework integration or explicit service options, not ad hoc controller code.

## Implementation Rules

- Prefer thin handlers that delegate to services or repositories immediately.
- Avoid returning ORM instances directly when the framework expects serialized schema objects.
- Keep pagination, filters, and loader options consistent across list and detail handlers.
- Fall back to repository-only handlers only when a service layer adds no value.

## Example Pattern

```python
@router.get("/authors")
async def list_authors(
    authors_service: AuthorService,
    limit_offset: LimitOffset,
) -> OffsetPagination[Author]:
    results, total = await authors_service.list_and_count(limit_offset)
    return authors_service.to_schema(results, total, filters=[limit_offset])
```

## Validation Checklist

- Confirm list routes preserve filtering and pagination semantics.
- Confirm write routes use the intended create and update schemas.
- Confirm delete handlers express empty responses cleanly.
- Confirm route handlers do not hide transaction boundaries or loader behavior.

## Cross-Skill Handoffs

- Use `advanced-alchemy-services` for business-rule-heavy endpoints.
- Use `advanced-alchemy-repositories` for repository-only patterns.
- Use `advanced-alchemy-litestar`, `advanced-alchemy-fastapi`, or `advanced-alchemy-flask` for framework syntax and DI details.

## Advanced Alchemy References

- https://advanced-alchemy.litestar.dev/latest/usage/routing.html
- https://advanced-alchemy.litestar.dev/latest/usage/frameworks/litestar.html
- https://advanced-alchemy.litestar.dev/latest/usage/frameworks/fastapi.html
