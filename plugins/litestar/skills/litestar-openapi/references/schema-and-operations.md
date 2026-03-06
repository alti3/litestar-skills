# Schema And Operations

## Table of Contents

- Basic `OpenAPIConfig`
- Disabling schema generation
- Route-level schema metadata
- Operation customization
- Accessing the schema in code

## Basic `OpenAPIConfig`

Litestar generates OpenAPI 3.1 docs by default and exposes JSON and YAML schema outputs.

```python
from litestar import Litestar, get
from litestar.openapi.config import OpenAPIConfig


@get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


app = Litestar(
    route_handlers=[health],
    openapi_config=OpenAPIConfig(title="Service API", version="1.0.0"),
)
```

Guidance:

- Keep title and version explicit.
- Configure global docs behavior at the app level first.

## Disabling Schema Generation

The OpenAPI docs note that schema generation is enabled by default and can be disabled with `openapi_config=None`.

```python
from litestar import Litestar


app = Litestar(route_handlers=[...], openapi_config=None)
```

Use this only when docs exposure is intentionally disabled.

## Route-Level Schema Metadata

The schema-generation docs describe route-level knobs including:

- `include_in_schema`
- `summary`
- `description`
- `response_description`
- `operation_id`
- `raises`
- `security`
- `tags`
- `operation_class`

```python
from litestar import get
from litestar.exceptions import PermissionDeniedException


@get(
    "/admin/report",
    summary="Read admin report",
    description="Return the current admin-only report.",
    response_description="The report payload",
    tags=["admin"],
    operation_id="readAdminReport",
    raises=[PermissionDeniedException],
    include_in_schema=True,
)
def admin_report() -> dict[str, str]:
    return {"status": "ok"}
```

Guidance:

- Keep route metadata close to the handler when it is operation-specific.
- Use `raises` only for exceptions that really belong in the contract.
- Keep security docs aligned with auth behavior from `litestar-authentication` and `litestar-security`.

## Operation Customization

The docs note that `operation_class` can be used to customize the generated operation object for a route.

Guidance:

- Reach for `operation_class` only when route-level metadata is not enough.
- Keep operation customization centralized and reviewed because it can alter schema semantics broadly.

## Accessing The Schema In Code

The OpenAPI docs cover accessing the generated schema in code.

Guidance:

- Use this when tests, exporters, or custom docs flows need the generated schema object.
- Keep schema access read-only unless the customization flow is explicit and centralized.
