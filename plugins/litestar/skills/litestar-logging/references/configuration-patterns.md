# Configuration Patterns

## Table of Contents

- Basic `LoggingConfig`
- Request and app logger access
- Picologging
- Custom logging config subclasses

## Basic `LoggingConfig`

Litestar configures application- and request-level logging through `LoggingConfig`.

```python
from litestar import Litestar, Request, get
from litestar.logging import LoggingConfig


@get("/")
def my_router_handler(request: Request) -> None:
    request.logger.info("inside a request")
    return None


logging_config = LoggingConfig(
    root={"level": "INFO", "handlers": ["queue_listener"]},
    formatters={
        "standard": {"format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s"}
    },
    log_exceptions="always",
)

app = Litestar(route_handlers=[my_router_handler], logging_config=logging_config)
```

Guidance:

- Use `queue_listener` in your handler/root configuration for async-friendly non-blocking logging.
- Keep formatter shape explicit so log ingestion remains stable.

## Request And App Logger Access

The docs show request-level logging via `request.logger`, and `LoggingConfig.configure()` can return a logger factory for app-level loggers.

```python
from litestar import Litestar, Request, get
from litestar.logging import LoggingConfig


logging_config = LoggingConfig(
    root={"level": "INFO", "handlers": ["queue_listener"]},
    formatters={
        "standard": {"format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s"}
    },
    log_exceptions="always",
)

logger = logging_config.configure()()


@get("/")
def my_router_handler(request: Request) -> None:
    request.logger.info("inside a request")
    logger.info("app-level log event")


app = Litestar(route_handlers=[my_router_handler], logging_config=logging_config)
```

## Picologging

The logging docs note that Litestar will default to picologging automatically if it is installed, and `LoggingConfig` also supports selecting the logging module explicitly.

Guidance:

- Use picologging when performance matters and the deployment environment supports it.
- Keep the logging module choice centralized and documented.

## Custom Logging Config Subclasses

The docs note that custom configs can be created by subclassing `BaseLoggingConfig` and implementing `configure()`.

Guidance:

- Subclass only when `LoggingConfig` cannot express the required behavior.
- Keep custom config classes small and infrastructure-focused.
- Prefer built-in configuration first so future Litestar updates remain easier to absorb.
