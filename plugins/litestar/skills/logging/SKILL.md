---
name: logging
description: Configure Litestar logging with logging_config, structured output patterns, request correlation, and production-safe log levels.
---

# Logging

Use this skill when adding or standardizing logs across a Litestar app.

## Workflow

1. Configure `logging_config` at app creation.
2. Define environment-specific log levels/handlers.
3. Add request correlation IDs and consistent event fields.
4. Keep sensitive payloads and secrets out of logs.

## Pattern

```python
from litestar import Litestar
from litestar.logging import LoggingConfig

app = Litestar(
    route_handlers=[],
    logging_config=LoggingConfig(),
)
```

## Logging Checklist

- Use structured logs in production.
- Include operation name, request ID, and status.
- Avoid duplicate logging between middleware and handlers.
- Reserve stack traces for actionable failure points.

## Litestar References

- https://docs.litestar.dev/latest/usage/logging.html
