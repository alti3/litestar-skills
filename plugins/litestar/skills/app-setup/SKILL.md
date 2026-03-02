---
name: app-setup
description: Build and configure Litestar applications, including base app initialization, route registration, app-level config, and startup/shutdown hooks.
---

# App Setup

Use this skill when the user needs to create a new Litestar app, structure an existing app, or configure core application settings.

## Workflow

1. Define a minimal `Litestar(...)` app and register route handlers.
2. Move handlers into routers as complexity grows.
3. Add app-level configuration (`debug`, `openapi_config`, `logging_config`, `dependencies`, `middleware`).
4. Add lifespan hooks for startup/shutdown needs.

## Minimal Pattern

```python
from litestar import Litestar, get

@get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}

app = Litestar(route_handlers=[health])
```

## Project Pattern

- Create a dedicated `app.py` entrypoint exporting `app`.
- Keep transport concerns (handlers/routers/controllers) separate from services.
- Register routers/controllers via `route_handlers=[...]` on the app.

## App-Level Config Checklist

- `debug` for local development only.
- `openapi_config` for API docs metadata.
- `logging_config` for structured logging.
- `dependencies` for cross-cutting service injection.
- `middleware` for request/response policies.
- lifespan hooks/events for startup resource initialization and cleanup.

## Litestar References

- https://docs.litestar.dev/latest/usage/applications.html
- https://docs.litestar.dev/latest/usage/routing/index.html
- https://docs.litestar.dev/latest/usage/events.html
