---
name: advanced-alchemy-repositories
description: Build Advanced Alchemy repository layers with sync or async repositories, slug-aware repositories, query repositories, bulk operations, filtering, and pagination. Use when implementing database access patterns, replacing handwritten CRUD, or standardizing query logic around SQLAlchemy models. Do not use for business-rule orchestration that belongs in services or for framework routing concerns.
---

# Repositories

## Execution Workflow

1. Choose the base repository class that matches the runtime: `SQLAlchemyAsyncRepository`, `SQLAlchemySyncRepository`, or a slug or query variant.
2. Set `model_type` immediately and keep repositories model-specific.
3. Use built-in filters and `list_and_count()` for list endpoints instead of reimplementing pagination logic.
4. Use bulk helpers for inserts, updates, upserts, and deletes when the workload is batch-shaped.
5. Keep transaction ownership outside the repository unless the framework integration explicitly handles commit behavior.

## Implementation Rules

- Keep repositories focused on persistence and query composition, not HTTP contracts.
- Prefer repository subclasses over duplicated ad hoc helper functions spread across handlers.
- Reach for query repositories only when custom SQL or aggregation work is materially different from standard CRUD.
- Keep loader options explicit so relationship behavior is predictable.

## Example Pattern

```python
from advanced_alchemy.repository import SQLAlchemyAsyncRepository


class PostRepository(SQLAlchemyAsyncRepository[Post]):
    model_type = Post
```

## Validation Checklist

- Confirm the repository type matches the session type.
- Confirm `model_type` points at the intended mapped class.
- Confirm list filters, counts, and pagination stay consistent under real data.
- Confirm bulk operations are tested against the target database dialect.

## Cross-Skill Handoffs

- Use `advanced-alchemy-modeling` before defining repositories.
- Use `advanced-alchemy-services` when handlers need schema conversion or domain rules.
- Use `advanced-alchemy-routing` or a framework skill when repository methods are exposed over HTTP.

## Advanced Alchemy References

- https://advanced-alchemy.litestar.dev/latest/usage/repositories.html
- https://github.com/litestar-org/advanced-alchemy/blob/main/README.md
