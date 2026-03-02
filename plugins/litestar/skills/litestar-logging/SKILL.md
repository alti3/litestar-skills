---
name: litestar-logging
description: Configure Litestar logging for structured output, environment-aware log levels, request correlation, and production-safe redaction. Use when establishing or refactoring application logging behavior. Do not use for metrics/tracing instrumentation that belongs in observability-focused skills.
---

# Logging

## Execution Workflow

1. Configure `logging_config` and handler/formatter strategy at app setup.
2. Define environment-specific level policies (dev vs staging vs production).
3. Ensure request correlation identifiers are attached consistently.
4. Standardize event fields for searchability and incident debugging.

## Implementation Rules

- Prefer structured logs over free-form strings in production.
- Redact secrets, auth data, and sensitive payload fields.
- Avoid duplicate logging at multiple layers for the same failure.
- Keep stack traces for actionable failure contexts.

## Example Pattern

```python
from litestar import Litestar
from litestar.logging import LoggingConfig

app = Litestar(
    route_handlers=[...],
    logging_config=LoggingConfig(),
)
```

## Validation Checklist

- Confirm startup logs include runtime mode and version context.
- Confirm request logs include route/method/status/correlation fields.
- Confirm sensitive fields are absent or redacted.
- Confirm error logs are sufficient for debugging without data leakage.

## Cross-Skill Handoffs

- Use `metrics` for quantitative SLO monitoring.
- Use `debugging` for incident-driven troubleshooting workflows.

## Litestar References

- https://docs.litestar.dev/latest/usage/logging.html
- https://docs.litestar.dev/latest/usage/debugging.html
