---
name: advanced-alchemy-flask
description: Integrate Advanced Alchemy with Flask using sync or async configs, Flask session access helpers, multiple binds, FlaskServiceMixin, JSON serialization helpers, and Flask CLI database commands. Use when adding Advanced Alchemy persistence to Flask applications or refactoring Flask SQLAlchemy code toward repository and service patterns. Do not use for framework-agnostic repository or model work.
---

# Flask

## Execution Workflow

1. Choose `SQLAlchemySyncConfig` by default, or `SQLAlchemyAsyncConfig` only when Flask async routes are intentional and supported.
2. Initialize `AdvancedAlchemy` with the app and use its session helpers rather than global engine state.
3. Use `bind_key` only when the application truly needs multiple databases.
4. Wrap CRUD-heavy services with `FlaskServiceMixin` when its `jsonify()` helper meaningfully simplifies responses.
5. Use `flask database` commands once migrations are wired through the extension.

## Implementation Rules

- Keep `commit_mode` explicit: `manual`, `autocommit`, or `autocommit_include_redirect`.
- Prefer request or app-context-managed sessions over module-level state.
- Translate Flask query params into Advanced Alchemy filters near the route boundary.
- Use async sessions in sync routes only with care; that path is documented as experimental.

## Example Pattern

```python
from advanced_alchemy.extensions.flask import AdvancedAlchemy, SQLAlchemySyncConfig
from flask import Flask

app = Flask(__name__)
alchemy = AdvancedAlchemy(
    SQLAlchemySyncConfig(connection_string="sqlite:///local.db", commit_mode="autocommit"),
    app,
)
```

## Validation Checklist

- Confirm sessions are opened inside request or app context and closed cleanly.
- Confirm the chosen commit mode matches endpoint behavior, including redirects if relevant.
- Confirm `flask database --help` exposes migration commands when expected.
- Confirm `FlaskServiceMixin.jsonify()` returns the intended serialization format.

## Cross-Skill Handoffs

- Use `advanced-alchemy-repositories` and `advanced-alchemy-services` for the persistence layer itself.
- Use `advanced-alchemy-cli` for migration command semantics behind Flask CLI wrappers.
- Use `advanced-alchemy-database-seeding` for fixture loading during app initialization or admin workflows.

## Advanced Alchemy References

- https://advanced-alchemy.litestar.dev/latest/usage/frameworks/flask.html
- https://github.com/litestar-org/advanced-alchemy/blob/main/README.md
