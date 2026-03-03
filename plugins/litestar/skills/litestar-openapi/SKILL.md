---
name: litestar-openapi
description: Configure Litestar OpenAPI generation and documentation UX, including schema generation plugins, operation metadata, UI configuration, security docs, examples, and multiple schema outputs. Use when API contract/docs quality must be implemented or corrected. Do not use for runtime business logic changes unrelated to API schema/documentation.
---

# OpenAPI

## Execution Workflow

1. Set app-level OpenAPI config (title/version/servers/tags and docs endpoints).
2. Add operation-level metadata (summaries, descriptions, responses, examples, tags).
3. Configure security scheme documentation for protected endpoints.
4. Tune UI behavior and schema generation plugins for your model ecosystem.
5. Validate generated docs against real request/response behavior.

## Implementation Rules

- Keep docs truthful to runtime behavior; do not document unsupported contracts.
- Reuse shared response schemas and examples to reduce drift.
- Keep schema customizations centralized and version-controlled.
- Treat OpenAPI changes as API changes requiring review.

## Example Pattern

```python
from litestar import Litestar
from litestar.openapi.config import OpenAPIConfig

app = Litestar(
    route_handlers=[...],
    openapi_config=OpenAPIConfig(title="Service API", version="1.0.0"),
)
```

## Validation Checklist

- Confirm generated schema includes all public operations and correct status models.
- Confirm example payloads and security docs match runtime auth behavior.
- Confirm OpenAPI UI endpoints are configured safely for each environment.
- Confirm schema generation remains stable in CI.

## Cross-Skill Handoffs

- Use `litestar-responses`, `litestar-requests`, and `litestar-dto` when contract mismatches originate in transport modeling.
- Use `litestar-authentication` when security scheme docs must reflect auth backends.

## Litestar References

- https://docs.litestar.dev/latest/usage/openapi/index.html
- https://docs.litestar.dev/latest/usage/openapi/0-basic-use.html
- https://docs.litestar.dev/latest/usage/openapi/1-route-operation.html
- https://docs.litestar.dev/latest/usage/openapi/schema_generation_plugins.html
- https://docs.litestar.dev/latest/usage/openapi/openapi-ui.html
- https://docs.litestar.dev/latest/usage/openapi/security_scheme.html
- https://docs.litestar.dev/latest/usage/openapi/response_examples.html
- https://docs.litestar.dev/latest/usage/openapi/request_examples.html
- https://docs.litestar.dev/latest/usage/openapi/multiple_openapi_schemas.html
