---
name: litestar-app-setup
description: Build and configure Litestar application entrypoints, global app configuration, layered route registration, lifespan wiring, and shared app state. Use when creating a new Litestar service, restructuring app initialization, or setting app-level defaults. Do not use for isolated handler logic that belongs in routing, requests, responses, or DTO-focused skills.
---

# App Setup

## Execution Workflow

1. Define the app entrypoint (`app.py`, `main.py`, or factory) and keep it importable by the CLI.
2. Register route handlers through routers/controllers instead of crowding the app module.
3. Configure global concerns on `Litestar(...)` (logging, dependencies, middleware, OpenAPI, exception handlers).
4. Choose startup/shutdown hooks or an async lifespan context manager for resource lifecycle.
5. Store shared resources in app state only when they are truly application-scoped.

## Implementation Rules

- Keep the app module focused on composition, not business logic.
- Apply layered configuration intentionally: app-level defaults, then narrow overrides at router/controller/handler layers.
- Prefer explicit `route_handlers=[...]` registration and avoid dynamic side effects during import.
- Keep `debug=True` local-only and tie runtime behavior to environment settings.

## Example Pattern

```python
from litestar import Litestar, get

@get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}

app = Litestar(route_handlers=[health])
```

## Validation Checklist

- Confirm CLI autodiscovery works (`litestar run` resolves the correct app).
- Confirm startup and shutdown hooks both run and release external resources.
- Confirm global dependencies/middleware apply to intended routes only.
- Confirm app-level configuration does not unintentionally override route-level settings.

## Cross-Skill Handoffs

- Use `litestar-routing` for endpoint grouping and path design.
- Use `litestar-events` and `litestar-lifecycle-hooks` for deeper lifecycle orchestration.
- Use `litestar-logging`, `litestar-middleware`, and `litestar-openapi` for their domain-specific configuration depth.

## Litestar References

- https://docs.litestar.dev/latest/usage/applications.html
- https://docs.litestar.dev/latest/usage/routing/index.html
- https://docs.litestar.dev/latest/usage/events.html
- https://docs.litestar.dev/latest/usage/lifecycle-hooks.html
