---
name: advanced-alchemy-fastapi
description: Integrate Advanced Alchemy with FastAPI using the extension, request-scoped session dependencies, repository and service providers, typed response models, and router composition. Use when building FastAPI CRUD APIs backed by Advanced Alchemy or replacing handwritten SQLAlchemy session handling with its extension patterns. Do not use for non-FastAPI framework integrations.
---

# FastAPI

## Execution Workflow

1. Configure `SQLAlchemyAsyncConfig` and attach `AdvancedAlchemy` to the FastAPI app.
2. Build request-scoped session dependencies with `Depends(alchemy.provide_session())`.
3. Provide services through async generators and `Service.new(session=...)` context managers.
4. Keep routers thin and return service-converted schema objects or paginated schema collections.
5. Register routers only after the service and dependency layer is coherent.

## Implementation Rules

- Use `Annotated` plus `Depends` for session and service injection to keep signatures explicit.
- Set `commit_mode` intentionally; do not rely on implicit transaction assumptions.
- Keep `response_model` aligned with the schema returned by `to_schema()`.
- Avoid passing ORM instances directly through FastAPI responses.

## Example Pattern

```python
from advanced_alchemy.extensions.fastapi import AdvancedAlchemy, AsyncSessionConfig, SQLAlchemyAsyncConfig
from fastapi import FastAPI

alchemy = AdvancedAlchemy(
    config=SQLAlchemyAsyncConfig(
        connection_string="sqlite+aiosqlite:///test.sqlite",
        session_config=AsyncSessionConfig(expire_on_commit=False),
        create_all=True,
        commit_mode="autocommit",
    ),
    app=FastAPI(),
)
```

## Validation Checklist

- Confirm the session dependency is request-scoped and closes after each request.
- Confirm service providers yield the expected service type and release resources.
- Confirm response models match the schema conversion output.
- Confirm routers are mounted only once and startup or shutdown lifecycle is not duplicated.

## Cross-Skill Handoffs

- Use `advanced-alchemy-routing` for CRUD endpoint shape.
- Use `advanced-alchemy-services` for service-backed FastAPI handlers.
- Use `advanced-alchemy-cli` if the project needs Advanced Alchemy migration commands alongside the app.

## Advanced Alchemy References

- https://advanced-alchemy.litestar.dev/latest/usage/frameworks/fastapi.html
- https://github.com/litestar-org/advanced-alchemy/blob/main/README.md
