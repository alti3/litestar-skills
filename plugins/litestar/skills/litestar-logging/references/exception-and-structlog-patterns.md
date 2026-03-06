# Exception And Structlog Patterns

## Table of Contents

- Exception logging policy
- Selective stack-trace suppression
- Structlog
- Redaction guidance

## Exception Logging Policy

The logging docs note that exceptions are not logged by default except in debug mode. Use `log_exceptions="always"` when production logging should include them.

```python
from litestar import Litestar
from litestar.logging import LoggingConfig


logging_config = LoggingConfig(
    root={"level": "INFO", "handlers": ["queue_listener"]},
    log_exceptions="always",
)

app = Litestar(logging_config=logging_config, route_handlers=[...])
```

Guidance:

- Treat exception logging policy as a production decision, not a default assumption.
- Keep client-facing exception responses separate from what gets logged internally.

## Selective Stack-Trace Suppression

Use `disable_stack_trace` to suppress traces for specific exception types or status codes.

```python
from litestar import Litestar
from litestar.logging import LoggingConfig


logging_config = LoggingConfig(
    debug=True,
    disable_stack_trace={404, ValueError},
    log_exceptions="always",
)

app = Litestar(logging_config=logging_config, route_handlers=[...])
```

Guidance:

- Suppress stack traces only for expected, high-volume errors.
- Keep traces for failures that still need debugging context.

## Structlog

The logging docs show Structlog integration via `StructlogPlugin`.

```python
from litestar import Litestar, Request, get
from litestar.plugins.structlog import StructlogPlugin


@get("/")
def my_router_handler(request: Request) -> None:
    request.logger.info("inside a request")
    return None


app = Litestar(route_handlers=[my_router_handler], plugins=[StructlogPlugin()])
```

Use this when:

- Structured logging is the project standard.
- Downstream log ingestion depends on consistent key-value output.

## Redaction Guidance

Practical defaults for Litestar logging:

- Never log raw secrets, tokens, or secret-bearing headers.
- Be cautious with request bodies, especially auth, upload, or personally identifying data.
- Keep redaction rules aligned with `litestar-security` and `litestar-requests`.
- Prefer adding stable contextual fields over dumping entire payloads.
