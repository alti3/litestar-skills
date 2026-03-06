# Dependency Markers

## Table of Contents

- Basic explicit dependency marker
- Skip validation for trusted values
- Default dependency value excluded from OpenAPI
- Fail fast on missing explicit dependency

## Basic Explicit Dependency Marker

Use `litestar.params.Dependency` with `Annotated[...]` when a parameter is definitely dependency-driven and should not be inferred as a client-supplied parameter.

```python
from typing import Annotated

from litestar.params import Dependency


CurrentUser = Annotated["User", Dependency()]
```

Use this when:

- A parameter is definitely a dependency.
- Missing registration should be a wiring error, not a query-parameter fallback.
- OpenAPI should describe client-facing inputs only.

## Skip Validation for Trusted Values

By default Litestar validates injected values against the annotated type. Disable validation only when the provider is trusted and validation is either too expensive or unsupported.

```python
from typing import Annotated, Any

from litestar import Litestar, get
from litestar.di import Provide
from litestar.params import Dependency


async def provide_payload() -> str:
    return "already-validated"


@get("/payload", dependencies={"payload": Provide(provide_payload)}, sync_to_thread=False)
def read_payload(payload: Annotated[str, Dependency(skip_validation=True)]) -> dict[str, Any]:
    return {"payload": payload}


app = Litestar(route_handlers=[read_payload])
```

Guidance:

- Keep validation enabled by default.
- Skip validation only for proven hot paths or types the validation layer cannot handle correctly.
- Document why validation is disabled when the choice is non-obvious.

## Default Dependency Value Excluded from OpenAPI

If a dependency has a sensible fallback and is not meant to be supplied by API consumers, mark it explicitly so Litestar does not treat it as a query parameter in OpenAPI.

```python
from typing import Annotated

from litestar import Litestar, get
from litestar.params import Dependency


@get("/report", sync_to_thread=False)
def read_report(limit: Annotated[int, Dependency(default=100)]) -> dict[str, int]:
    return {"limit": limit}


app = Litestar(route_handlers=[read_report])
```

## Fail Fast on Missing Explicit Dependency

Use an explicit dependency marker with no default when missing registration should be a startup error rather than a runtime surprise.

```python
from typing import Annotated, Any

from litestar import Litestar, get
from litestar.params import Dependency


@get("/")
def hello_world(non_optional_dependency: Annotated[int, Dependency()]) -> dict[str, Any]:
    return {"value": non_optional_dependency}


app = Litestar(route_handlers=[hello_world])
# ImproperlyConfiguredException at startup if the dependency is not provided.
```
