---
name: advanced-alchemy-litestar
description: Integrate Advanced Alchemy with Litestar using the SQLAlchemy plugin, session injection, service and repository providers, DTO-friendly models, CLI database commands, and optional session backends. Use when building or refactoring Litestar applications that persist data through Advanced Alchemy. Do not use for generic Litestar work that does not depend on Advanced Alchemy.
---

# Litestar

## Execution Workflow

1. Configure `SQLAlchemyAsyncConfig` or `SQLAlchemySyncConfig` and register `SQLAlchemyPlugin`.
2. Use the plugin to provide session and engine dependencies instead of hand-rolling request-scoped session management.
3. Build controllers around services first, and fall back to repository-only patterns only when they stay simpler.
4. Keep application composition in `Litestar(...)` and let providers or DI supply services.
5. Enable CLI database commands and optional session-backend support only after the core CRUD path is stable.

## Implementation Rules

- Prefer a single canonical plugin configuration per application.
- Keep `before_send_handler` and session dependency keys explicit when changing defaults.
- Use controller or handler injection for `db_session` only when service injection is unnecessary.
- Keep DTO or schema shaping close to the controller boundary, not inside repositories.

## Example Pattern

```python
from advanced_alchemy.extensions.litestar import (
    AsyncSessionConfig,
    SQLAlchemyAsyncConfig,
    SQLAlchemyPlugin,
)
from litestar import Litestar

alchemy_config = SQLAlchemyAsyncConfig(
    connection_string="sqlite+aiosqlite:///test.sqlite",
    before_send_handler="autocommit",
    session_config=AsyncSessionConfig(expire_on_commit=False),
    create_all=True,
)

app = Litestar(plugins=[SQLAlchemyPlugin(config=alchemy_config)])
```

## Validation Checklist

- Confirm Litestar injects the expected `db_session` or renamed dependency.
- Confirm request lifecycle commit and rollback behavior matches `before_send_handler`.
- Confirm `litestar database` commands are available when the plugin is installed.
- Confirm route handlers, providers, and DTOs agree on model and schema types.

## Cross-Skill Handoffs

- Use `advanced-alchemy-routing` for CRUD route structure.
- Use `advanced-alchemy-services` for service-backed controllers.
- Use `advanced-alchemy-cli` for migration commands exposed through Litestar CLI.
- Use `litestar-app-setup`, `litestar-dependency-injection`, or `litestar-dto` for deeper Litestar-only concerns.

## Advanced Alchemy References

- https://github.com/litestar-org/advanced-alchemy/blob/main/examples/litestar/litestar_service.py
- https://advanced-alchemy.litestar.dev/latest/usage/frameworks/litestar.html
- https://github.com/litestar-org/advanced-alchemy/blob/main/README.md
