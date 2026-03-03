---
name: litestar-plugins
description: Configure Litestar plugins for serialization/model integration (Pydantic, dataclass, msgspec, attrs, TypedDict) and persistence integrations (SQLAlchemy, Piccolo). Use when selecting or wiring plugin-based behavior at app boundaries. Do not use for unrelated framework configuration that does not involve plugin architecture.
---

# Plugins

## Execution Workflow

1. Select plugins based on data model and persistence strategy.
2. Register plugins at app creation with explicit configuration.
3. Validate request parsing, response serialization, and DTO interplay.
4. Add compatibility tests for plugin-specific edge cases.

## Implementation Rules

- Prefer the minimum plugin set that satisfies requirements.
- Keep plugin behavior documented and version-aware.
- Avoid mixing overlapping serializer ecosystems without clear rationale.
- Validate plugin interaction with OpenAPI and DTO contracts.

## Example Pattern

```python
from litestar import Litestar

app = Litestar(
    route_handlers=[...],
    plugins=[...],  # e.g., pydantic/msgspec/sqlalchemy plugin instance
)
```

## Validation Checklist

- Confirm plugin registration order and config are deterministic.
- Confirm serialization/deserialization behavior matches expectations.
- Confirm schema generation remains accurate across plugin-backed models.

## Cross-Skill Handoffs

- Use `litestar-databases` for ORM plugin deep dives.
- Use `litestar-dto`, `litestar-requests`, and `litestar-responses` for transport contract shaping.

## Litestar References

- https://docs.litestar.dev/latest/usage/plugins/index.html
- https://docs.litestar.dev/latest/usage/plugins/sqlalchemy.html
- https://docs.litestar.dev/latest/usage/plugins/piccolo.html
- https://docs.litestar.dev/latest/usage/plugins/pydantic.html
- https://docs.litestar.dev/latest/usage/plugins/dataclass.html
- https://docs.litestar.dev/latest/usage/plugins/msgspec.html
- https://docs.litestar.dev/latest/usage/plugins/attrs.html
- https://docs.litestar.dev/latest/usage/plugins/typed-dict.html
