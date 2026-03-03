---
name: litestar-databases
description: Build Litestar database architecture with SQLAlchemy and Piccolo, including model/repository patterns, plugin setup, session lifecycle, and serialization boundaries. Use when implementing persistence layers, transaction handling, or ORM integration. Do not use for non-persistent in-memory workflows.
---

# Databases

## Execution Workflow

1. Choose ORM path (SQLAlchemy or Piccolo) based on project constraints.
2. Configure plugins and session lifecycle at app initialization.
3. Define model/repository boundaries and transaction ownership.
4. Integrate dependency injection for per-request unit-of-work patterns.
5. Validate serialization and lazy-loading behavior at API boundaries.

## Implementation Rules

- Keep transaction boundaries explicit and short-lived.
- Keep repositories/services free of HTTP transport concerns.
- Avoid leaking ORM internals directly in response contracts.
- Prefer deterministic session ownership and cleanup.

## Example Pattern

```python
from litestar import Litestar
from litestar.contrib.sqlalchemy.plugins import SQLAlchemyPlugin

sqlalchemy_plugin = SQLAlchemyPlugin(...)
app = Litestar(route_handlers=[...], plugins=[sqlalchemy_plugin])
```

## Validation Checklist

- Confirm migrations/model metadata align with runtime models.
- Confirm startup/shutdown initialize and release DB resources.
- Confirm rollback behavior on exceptions is tested.
- Confirm N+1 and lazy-loading pitfalls are addressed in hot paths.

## Cross-Skill Handoffs

- Use `litestar-dependency-injection` for session provisioning patterns.
- Use `litestar-dto` and `litestar-responses` for safe transport shaping.
- Use `litestar-testing` for transactional test isolation.

## Litestar References

- https://docs.litestar.dev/latest/usage/databases/index.html
- https://docs.litestar.dev/latest/usage/databases/sqlalchemy/index.html
- https://docs.litestar.dev/latest/usage/databases/sqlalchemy/models_and_repository.html
- https://docs.litestar.dev/latest/usage/databases/sqlalchemy/plugins/index.html
- https://docs.litestar.dev/latest/usage/databases/sqlalchemy/plugins/sqlalchemy_plugin.html
- https://docs.litestar.dev/latest/usage/databases/sqlalchemy/plugins/sqlalchemy_init_plugin.html
- https://docs.litestar.dev/latest/usage/databases/sqlalchemy/plugins/sqlalchemy_serialization_plugin.html
- https://docs.litestar.dev/latest/usage/databases/piccolo.html
